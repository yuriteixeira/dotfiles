---
name: grafana-dashboard-playwright
description: Edit and extract Grafana dashboard JSON models through an authenticated visible browser session using playwright-cli. Use when changing Grafana dashboards, inlining library panels, updating panel SQL, exporting JSON models, or safely saving dashboard changes without modifying shared library panels.
allowed-tools: Bash(playwright-cli:*) Bash(python3:*) Read Write
---

# Grafana Dashboard Editing with playwright-cli

Use this skill to modify Grafana dashboards through the user's authenticated browser session while keeping the browser visible. Prefer Grafana's authenticated HTTP API from `playwright-cli run-code` for bulk dashboard JSON changes; use UI clicks only for inspection or one-off validation.

## Core principles

- Use a headed, authenticated browser session. If the user wants their existing Chrome session, attach via CDP:
  - Ask the user to enable `chrome://inspect/#remote-debugging` → “Allow remote debugging for this browser instance”.
  - Run `playwright-cli attach --cdp=chrome`.
  - Use `playwright-cli --s=chrome ...` for commands.
- Avoid editing shared library panels directly unless the user explicitly wants propagation.
- To make a dashboard self-contained, fetch each library element, copy `result.model` into the dashboard panel, preserve the dashboard panel's `id`, `gridPos`, and title, then delete `libraryPanel`.
- Before adding a SQL filter, verify the target table has the column. Do not add filters to panels querying tables that lack the column.
- After saving, verify by re-fetching `/api/dashboards/uid/<uid>` and checking the persisted model.
- Export the current JSON model from Grafana after changes; do not rely on stale local JSON exports.

## Useful Grafana API endpoints

From an authenticated page at the Grafana host:

```js
await fetch('/api/dashboards/uid/<dashboardUid>')
await fetch('/api/library-elements/<libraryPanelUid>')
await fetch('/api/dashboards/db', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({ dashboard, folderUid, message, overwrite: true }) })
```

## Export current dashboard JSON model

Use `scripts/export-dashboard.js` with `playwright-cli run-code`, then decode the returned JSON string literal:

```bash
playwright-cli --s=chrome --raw run-code --filename=/Users/yuriteixeira/.pi/agent/skills/grafana-dashboard-playwright/scripts/export-dashboard.js -- <dashboardUid> > /tmp/dashboard_export_quoted.txt
python3 - <<'PY'
import json
from pathlib import Path
raw = Path('/tmp/dashboard_export_quoted.txt').read_text()
dashboard_text = json.loads(raw)
Path('new-grafana.json').write_text(dashboard_text + '\n')
PY
```

If the script argument form is inconvenient, create a temporary script with the dashboard UID embedded.

## Inline library panels safely

Use the pattern from `scripts/inline-library-panels.js`:

1. Fetch dashboard by UID.
2. Recursively flatten panels, including panels nested inside row panels.
3. For each target panel with `libraryPanel.uid`:
   - Fetch `/api/library-elements/<uid>`.
   - Clone `result.model`.
   - Preserve the dashboard panel's `id`, `gridPos`, and visible `title`.
   - Delete `libraryPanel`.
   - Assign the cloned model back onto the dashboard panel object.
4. Save via `/api/dashboards/db` with the original `folderUid` and `overwrite: true`.
5. Re-fetch and verify `libraryPanel` is absent and `targets` are present.

## Add SQL filters to panels

When adding a dashboard variable filter to SQL panels:

- Find panels by table name in `targets[].rawSql`.
- Insert the filter after the `_TABLE_SUFFIX` date filter when present:

```sql
WHERE _TABLE_SUFFIX BETWEEN '${__from:date:YYYYMMDD}' AND '${__to:date:YYYYMMDD}'
AND my_column LIKE $my_variable
```

- Match the dashboard's existing variable interpolation style. For BigQuery panels in this repo, variables with `allValue: "'%'"` often use bare `$variable`; variables requiring explicit single quoting may use `${variable:singlequote}`.
- Run/validate at least one representative panel in the UI or via network/API behavior before bulk edits.

## Verification checklist

After saving, run a verification script that reports:

- dashboard version
- non-row panel count
- number/list of remaining `libraryPanel` refs
- panels without `targets`
- expected table panels and whether the new filter exists
- excluded table panels and whether the unsupported filter was accidentally added

Example verification logic:

```js
const allPanels = panels => panels.flatMap(panel => panel.panels ? [panel, ...allPanels(panel.panels)] : [panel]);
const realPanels = allPanels(dashboard.panels).filter(panel => panel.type !== 'row');
const libraryRefs = realPanels.filter(panel => panel.libraryPanel);
const withoutTargets = realPanels.filter(panel => !panel.targets?.length);
```

## UI pitfalls learned

- Grafana edit-panel route (`editPanel=<id>`) can be flaky for lower/collapsed panels.
- Monaco editor changes are not always persisted until the panel edit is applied/backed out to the dashboard and the dashboard save fully commits.
- The save drawer can show “No changes to save” if the panel edit has not been applied to the dashboard model.
- `beforeunload` prompts can block automation; handle with `playwright-cli dialog-accept` when safe.
- API-backed model changes are usually faster and more reliable than clicking through many panels.

## Safety notes

- Do not save changes to shared library elements unless explicitly requested.
- Prefer inlining to isolate changes to a copy/template dashboard.
- Keep a local JSON export before and after large changes.
- Use a clear dashboard save message.
