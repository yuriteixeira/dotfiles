#!/usr/bin/env bash

set -u

readonly WINDOW_FORMAT='%{window-id} %{window-is-fullscreen} %{window-title} %{window-layout} %{window-parent-container-layout} %{workspace} %{workspace-is-focused} %{workspace-is-visible} %{workspace-root-container-layout} %{app-bundle-id} %{app-name} %{app-pid} %{app-exec-path} %{app-bundle-path} %{monitor-name}'
readonly WORKSPACE_FORMAT='%{workspace} %{workspace-is-focused} %{workspace-is-visible} %{monitor-name}'
readonly MONITOR_FORMAT='%{monitor-id} %{monitor-name} %{monitor-is-main}'
readonly SESSIONS_DIRECTORY="$HOME/.local/share/aerospace/sessions"
readonly LAUNCH_SCRIPT="$HOME/.config/aerospace/scripts/launch-session.sh"

fail() {
  printf 'aerospace-session: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

require_command aerospace
require_command jq

if [ "$#" -gt 1 ]; then
  fail 'usage: save-session.sh [OUTPUT_FILE]'
fi

output_path=${1:-}
if [ -z "$output_path" ]; then
  mkdir -p "$SESSIONS_DIRECTORY"
  output_path="$SESSIONS_DIRECTORY/session-$(date '+%Y%m%d-%H%M%S').json"
else
  mkdir -p "$(dirname "$output_path")"
fi

# These are read-only AeroSpace queries. Saving never changes workspace,
# window, monitor, or mouse focus.
windows=$(aerospace list-windows --all --json --format "$WINDOW_FORMAT") || \
  fail 'could not query AeroSpace windows'
[ "$(printf '%s' "$windows" | jq 'length')" -gt 0 ] || \
  fail 'there are no AeroSpace-managed windows to save'
windows=$(printf '%s' "$windows" | jq 'to_entries | map(.value + {"capture-index": .key})')

workspaces=$(aerospace list-workspaces --all --json --format "$WORKSPACE_FORMAT") || \
  fail 'could not query AeroSpace workspaces'
monitors=$(aerospace list-monitors --json --format "$MONITOR_FORMAT") || \
  fail 'could not query AeroSpace monitors'
focused_window_id=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null || true)

snapshot=$(jq -n \
  --arg captured_at "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  --arg aerospace_version "$(aerospace --version | head -n 1)" \
  --argjson focused_window_id "${focused_window_id:-null}" \
  --argjson windows "$windows" \
  --argjson workspaces "$workspaces" \
  --argjson monitors "$monitors" \
  '{
    "captured-at": $captured_at,
    "aerospace-version": $aerospace_version,
    "focused-window-id": $focused_window_id,
    windows: $windows,
    workspaces: $workspaces,
    monitors: $monitors
  }') || fail 'could not build the session snapshot'

printf '%s\n' "$snapshot" > "$output_path" || fail "could not write session: $output_path"

if [ -z "${1:-}" ]; then
  ln -sfn "$(basename "$output_path")" "$SESSIONS_DIRECTORY/latest.json"
fi

printf 'Saved %s apps and %s windows to:\n%s\n\nLaunch with:\n%s %s\n' \
  "$(printf '%s' "$windows" | jq '[.[]."app-bundle-id"] | unique | length')" \
  "$(printf '%s' "$windows" | jq 'length')" \
  "$output_path" \
  "$LAUNCH_SCRIPT" \
  "$output_path"
