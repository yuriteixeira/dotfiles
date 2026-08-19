#!/usr/bin/env bash

set -u

SESSION_FILE=${AEROSPACE_SESSION_FILE:-"$HOME/.local/share/aerospace/sessions/latest.json"}
WAIT_SECONDS=${AEROSPACE_SESSION_WAIT_SECONDS:-8}
DRY_RUN=false
LAUNCH_APPS=true

fail() {
  printf 'aerospace-session: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'aerospace-session: warning: %s\n' "$*" >&2
}

run() {
  printf '  '
  printf '%q ' "$@"
  printf '\n'
  [ "$DRY_RUN" = true ] || "$@"
}

usage() {
  cat <<'USAGE'
Usage: launch-session.sh [SESSION_FILE] [--dry-run] [--no-launch] [--wait SECONDS]
USAGE
}

if [ "$#" -gt 0 ] && [ "${1#-}" = "$1" ]; then
  SESSION_FILE=$1
  shift
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --no-launch) LAUNCH_APPS=false; shift ;;
    --wait)
      [ "$#" -ge 2 ] || fail '--wait requires a number of seconds'
      WAIT_SECONDS=$2
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

case "$WAIT_SECONDS" in
  ''|*[!0-9]*) fail '--wait must be a non-negative integer' ;;
esac

command -v aerospace >/dev/null 2>&1 || fail 'required command not found: aerospace'
command -v jq >/dev/null 2>&1 || fail 'required command not found: jq'
[ -f "$SESSION_FILE" ] || fail "session file not found: $SESSION_FILE"

SESSION_JSON=$(jq -c 'select(.windows | type == "array")' "$SESSION_FILE") || \
  fail "invalid session JSON: $SESSION_FILE"
[ -n "$SESSION_JSON" ] || fail "session JSON has no windows array: $SESSION_FILE"

printf 'aerospace-session: restoring %s\n' "$SESSION_FILE"

if [ "$LAUNCH_APPS" = true ]; then
  while IFS=$'\t' read -r bundle_id bundle_path app_name; do
    printf 'aerospace-session: launching %s\n' "$app_name"
    if [ -n "$bundle_id" ]; then
      run open -g -b "$bundle_id" || {
        [ -n "$bundle_path" ] && run open -g "$bundle_path"
      }
    elif [ -n "$bundle_path" ]; then
      run open -g "$bundle_path" || true
    else
      warn "cannot launch $app_name: bundle information is missing"
    fi
  done < <(printf '%s' "$SESSION_JSON" | jq -r '
    [.windows[] | [.["app-bundle-id"], .["app-bundle-path"], .["app-name"]]]
    | unique | .[] | @tsv')

  if [ "$DRY_RUN" = false ] && [ "$WAIT_SECONDS" -gt 0 ]; then
    printf 'aerospace-session: waiting %ss for windows\n' "$WAIT_SECONDS"
    sleep "$WAIT_SECONDS"
  fi
fi

CURRENT_WINDOWS=$(aerospace list-windows --all --json --format \
  '%{window-id} %{window-title} %{app-bundle-id} %{app-exec-path}') || \
  fail 'could not query current AeroSpace windows'

# Match exact app/title pairs first, then pair remaining windows by app order.
# Removing each match from "available" guarantees one current window per record.
ASSIGNMENTS=$(jq -n --argjson session "$SESSION_JSON" --argjson current "$CURRENT_WINDOWS" '
  def same_app($desired; $actual):
    if ($desired["app-bundle-id"] // "") != "" then
      $desired["app-bundle-id"] == $actual["app-bundle-id"]
    else
      $desired["app-exec-path"] == $actual["app-exec-path"]
    end;

  def candidate($desired; $available; $exact):
    [range(0; $available | length)
      | select(same_app($desired; $available[.]))
      | select(if $exact then
          $desired["window-title"] == $available[.]["window-title"]
        else true end)
    ][0] // null;

  def assign($state; $index; $exact):
    $state.items[$index].desired as $desired
    | candidate($desired; $state.available; $exact) as $candidate
    | if $candidate == null then $state
      else $state
        | .items[$index].current_id = .available[$candidate]["window-id"]
        | .items[$index].match = (if $exact then "exact" else "fallback" end)
        | .available |= del(.[$candidate])
      end;

  {
    items: [$session.windows[] | {desired: ., current_id: null, match: "missing"}],
    available: $current
  }
  | reduce range(0; .items | length) as $index
      (.; assign(.; $index; true))
  | reduce range(0; .items | length) as $index
      (.; if .items[$index].current_id == null
          then assign(.; $index; false)
          else . end)
  | .items
') || fail 'could not match reopened windows'

CURRENT_MONITORS=$(aerospace list-monitors --json --format '%{monitor-name}')
while IFS=$'\t' read -r workspace monitor_name available; do
  if [ "$available" = true ]; then
    run aerospace move-workspace-to-monitor --workspace "$workspace" -- "$monitor_name" || true
  else
    warn "monitor '$monitor_name' is unavailable for workspace '$workspace'"
  fi
done < <(printf '%s' "$SESSION_JSON" | jq -r --argjson current "$CURRENT_MONITORS" '
  .workspaces[] as $workspace
  | [$workspace.workspace, $workspace["monitor-name"],
     (any($current[]; .["monitor-name"] == $workspace["monitor-name"]))]
  | @tsv')

while IFS=$'\t' read -r window_id workspace layout fullscreen app_name; do
  if [ -z "$window_id" ]; then
    warn "no reopened window matched for $app_name"
    continue
  fi

  printf 'aerospace-session: restoring %s on workspace %s\n' "$app_name" "$workspace"
  run aerospace move-node-to-workspace --window-id "$window_id" -- "$workspace" || true
  run aerospace layout --window-id "$window_id" "$layout" || true
  run aerospace fullscreen --window-id "$window_id" "$fullscreen" || true
done < <(printf '%s' "$ASSIGNMENTS" | jq -r '
  sort_by(.desired.workspace, .desired["capture-index"])
  | .[]
  | [(.current_id // ""), .desired.workspace, .desired["window-layout"],
     (if .desired["window-is-fullscreen"] then "on" else "off" end),
     .desired["app-name"]]
  | @tsv')

while IFS=$'\t' read -r workspace layout; do
  run aerospace layout --workspace "$workspace" --root "$layout" || true
done < <(printf '%s' "$ASSIGNMENTS" | jq -r '
  [.[] | select(.current_id != null) | .desired]
  | unique_by(.workspace)[]
  | [.workspace, .["workspace-root-container-layout"]]
  | @tsv')

while IFS= read -r workspace; do
  run aerospace workspace -- "$workspace" || true
done < <(printf '%s' "$SESSION_JSON" | jq -r '
  .workspaces[] | select(.["workspace-is-visible"] == true) | .workspace')

FOCUSED_SNAPSHOT_ID=$(printf '%s' "$SESSION_JSON" | jq -r '.["focused-window-id"] // empty')
if [ -n "$FOCUSED_SNAPSHOT_ID" ]; then
  FOCUSED_CURRENT_ID=$(printf '%s' "$ASSIGNMENTS" | jq -r \
    --argjson wanted "$FOCUSED_SNAPSHOT_ID" \
    '.[] | select(.desired["window-id"] == $wanted) | .current_id // empty')
  [ -z "$FOCUSED_CURRENT_ID" ] || run aerospace focus --window-id "$FOCUSED_CURRENT_ID" || true
fi

MATCHED=$(printf '%s' "$ASSIGNMENTS" | jq '[.[] | select(.current_id != null)] | length')
TOTAL=$(printf '%s' "$ASSIGNMENTS" | jq 'length')
printf 'aerospace-session: restored %s of %s captured windows\n' "$MATCHED" "$TOTAL"
