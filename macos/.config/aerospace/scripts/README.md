# AeroSpace session snapshots

Session data and launch behavior are intentionally separate:

- `save-session.sh` performs read-only AeroSpace queries and writes a JSON snapshot.
- `launch-session.sh` contains the reusable application-launch and window-restoration logic.

## Save

```sh
~/.config/aerospace/scripts/save-session.sh
```

Snapshots are written to:

```text
~/.local/share/aerospace/sessions/session-YYYYMMDD-HHMMSS.json
```

`latest.json` points to the newest snapshot. To choose another destination:

```sh
~/.config/aerospace/scripts/save-session.sh ~/my-session.json
```

Saving calls only these read-only AeroSpace CLI queries:

- `list-windows --all`
- `list-windows --focused`
- `list-workspaces --all`
- `list-monitors`
- `--version`

It never changes workspace, window, monitor, mouse, or keyboard focus.

Generated JSON files contain captured window titles, so review them before sharing or committing them.

## Launch

Launch the latest snapshot:

```sh
~/.config/aerospace/scripts/launch-session.sh
```

Launch a specific snapshot:

```sh
~/.config/aerospace/scripts/launch-session.sh \
  ~/.local/share/aerospace/sessions/session-YYYYMMDD-HHMMSS.json
```

Useful options:

```sh
launch-session.sh SESSION_FILE --dry-run
launch-session.sh SESSION_FILE --no-launch
launch-session.sh SESSION_FILE --wait 15
```

`--wait` is one fixed startup delay, not a polling loop. Its default is eight seconds and it can also be configured with `AEROSPACE_SESSION_WAIT_SECONDS`. The launcher then captures reopened windows once and applies one move/layout/fullscreen command set per matched window.

## Limitations

AeroSpace does not expose complete container-tree traversal order or pixel geometry through its list commands. The snapshot therefore stores the order returned by `list-windows`, along with the reported workspace, monitor, root, parent, tiled/floating, and fullscreen properties. Nested container placement and exact sizing can only be approximated.

Applications are launched once by bundle identifier. Browser tabs, documents, terminal commands, and window counts must be restored by each application's own macOS session-restoration support. The launcher matches exact app/title pairs first, falls back to reported window order when titles changed, and reapplies the AeroSpace arrangement to every matched window.
