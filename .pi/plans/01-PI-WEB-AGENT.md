# pi-web-agent research notes

## Short answer

Using `@demigodmode/pi-web-agent` looks like a good idea for this setup, especially if the goal is to keep local SearXNG as the preferred search backend while gaining explicit fallback to DuckDuckGo or Brave when your server is off.

My recommendation: use `pi-web-agent` with `compact` presentation, configure search as `searxng`, and opt into fallback deliberately:

```json
{
  "presentation": {
    "defaultMode": "compact"
  },
  "backends": {
    "search": {
      "provider": "searxng",
      "baseUrl": "http://yuri-studio.local:8000",
      "fallback": "duckduckgo"
    },
    "fetch": {
      "provider": "http"
    },
    "headless": {
      "provider": "local-browser"
    }
  }
}
```

Use Brave instead of DuckDuckGo fallback if you want API-backed hosted source discovery and are okay setting `PI_WEB_AGENT_BRAVE_API_KEY` in the environment.

## Why I think it is worth switching

### Pros

- **Keeps SearXNG available**: `pi-web-agent` can use SearXNG directly via `/search?q=...&format=json`.
- **Fixes the “server is off” failure mode**: fallback is supported from SearXNG to DuckDuckGo, and Brave can also fall back to DuckDuckGo.
- **Better research workflow than search-only tools**: `web_explore` does search, page reads, selected headless rendering, evidence ranking, source-quality checks, and caveats inside one bounded workflow.
- **Less transcript noise by default**: compact mode returns a short summary such as “Reviewed 3 sources · synthesized answer with 3 findings”.
- **Failure transparency**: fallback is opt-in and reported when it happens; weak evidence is surfaced as caveats instead of fake confidence.

### Cons / tradeoffs

- **More hidden prompt/schema than a tiny SearXNG tool**: the extension injects a short system-prompt instruction and exposes a richer `web_explore` tool description.
- **More moving parts**: it depends on Node packages including `playwright`, `jsdom`, `cheerio`, and `@mozilla/readability`.
- **Headless fallback can be heavier**: browser rendering uses a local Chromium-family browser if found, otherwise Playwright-managed Chromium.
- **Third-party package risk**: Pi’s package catalog warns that packages can execute code and affect agent behavior, so the source should be reviewed before install.
- **License**: `AGPL-3.0-only`.

## Context pollution assessment

`pi-web-agent` is probably a modest increase in hidden context compared with a minimal SearXNG-only tool, but not a large one.

From the current source, it adds roughly:

- one public tool: `web_explore`
- a short parameter schema: `{ query: string }`
- a tool description of about 198 characters / 25 words
- a parameter description of about 33 characters / 5 words
- a `before_agent_start` system-prompt addition of about 397 characters / 55 words telling the model to use `web_explore` for web research and not raw shell/network commands

The bigger context risk is not the hidden schema. It is **tool output volume**. `pi-web-agent` addresses this with presentation modes:

- `compact` — shortest useful output, default
- `preview` — findings with internal provenance
- `verbose` — findings, sources, caveats, and provenance

For your concern, keep `compact` as the default. Switch to `preview` or `verbose` only when debugging research behavior.

## Comparison with direct SearXNG tool

| Area | Direct SearXNG | `pi-web-agent` |
| --- | --- | --- |
| Hidden prompt/schema | Very small | Still small, but larger due to `web_explore` guidance |
| Search backend | Your SearXNG only | DuckDuckGo default; configurable SearXNG or Brave |
| Fallback when local server is off | Usually no | Yes, but explicit/opt-in |
| Fetch pages | Usually separate/manual | Built in |
| Dynamic pages | Usually no | Targeted headless rendering |
| Evidence quality checks | Usually model/manual | Built in: diversity, unreadable/bot-check/conflict signals |
| Transcript noise | Depends on tool output | Compact by default, configurable |
| Privacy control | Strongest if only local SearXNG | Good if fallback disabled; weaker if fallback enabled |

## Research findings

- `@demigodmode/pi-web-agent` v1.5.1 is published as a Pi package for web access with one public tool, `web_explore`.
- The package intentionally keeps lower-level search/fetch/headless steps internal rather than exposing many public model-facing tools.
- Supported search backends are DuckDuckGo, SearXNG, and Brave.
- Supported fetch backends are plain HTTP and Firecrawl.
- SearXNG fallback to DuckDuckGo is explicit; it does not silently leave a self-hosted backend unless configured.
- Brave Search support was added in v1.5.0 and uses `PI_WEB_AGENT_BRAVE_API_KEY`.
- SearXNG’s official API supports `/search?q=...&format=json`, but JSON output must be enabled in the SearXNG instance config.
- Brave’s API docs describe Web Search as a large hosted index, with freshness filtering, country/language targeting, operators, and result snippets.

## Suggested setup path

1. Install:

   ```bash
   pi install npm:@demigodmode/pi-web-agent
   ```

2. Reload/restart Pi.

3. Run:

   ```text
   /web-agent doctor
   ```

4. Configure via:

   ```text
   /web-agent settings
   ```

5. Set:

   - presentation: `compact`
   - search provider: `searxng`
   - SearXNG URL: `http://yuri-studio.local:8000`
   - fallback: `duckduckgo` or `brave` depending on preference/API key availability
   - fetch provider: `http`
   - headless: `local-browser`

6. Verify:

   ```text
   /web-agent show
   /web-agent doctor
   ```

## Bottom line

I would switch, but configure it conservatively:

- `compact` output
- local SearXNG as primary
- explicit fallback enabled only if you accept requests going outside your local SearXNG when it is down
- Brave only if you want better hosted discovery and are okay with an API key

This gives you the resilience you want while keeping context pollution reasonably low.

## Sources

- pi-web-agent package page: https://pi.dev/packages/@demigodmode/pi-web-agent
- pi-web-agent GitHub repository: https://github.com/demigodmode/pi-web-agent
- pi-web-agent docs: https://demigodmode.github.io/pi-web-agent/
- pi-web-agent backends docs: https://demigodmode.github.io/pi-web-agent/self-hosted-backends
- SearXNG Search API docs: https://docs.searxng.org/dev/search_api.html
- Brave Search API docs: https://api-dashboard.search.brave.com/app/documentation/web-search/get-started
