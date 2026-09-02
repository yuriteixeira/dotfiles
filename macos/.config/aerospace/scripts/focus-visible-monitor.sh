#!/usr/bin/env bash

set -euo pipefail

readonly DIRECTION=${1:-}
readonly FOCUSED_MONITOR=$(aerospace list-workspaces --focused --format '%{monitor-id}')
readonly MONITOR_COUNT=$(aerospace list-monitors --count)

case "$DIRECTION" in
  next)
    TARGET_MONITOR=$((FOCUSED_MONITOR % MONITOR_COUNT + 1))
    ;;
  prev)
    TARGET_MONITOR=$(((FOCUSED_MONITOR + MONITOR_COUNT - 2) % MONITOR_COUNT + 1))
    ;;
  *)
    printf 'usage: %s (next|prev)\n' "$0" >&2
    exit 1
    ;;
esac

readonly TARGET_MONITOR
readonly VISIBLE_WORKSPACE=$(aerospace list-workspaces \
  --monitor "$TARGET_MONITOR" \
  --visible)

if [ -z "$VISIBLE_WORKSPACE" ]; then
  printf 'No visible workspace found on monitor %s\n' "$TARGET_MONITOR" >&2
  exit 1
fi

# AeroSpace issue #101 can redirect the first focus request to another window of
# the same app on a different monitor. Retrying the same workspace corrects it.
readonly MAX_FOCUS_ATTEMPTS=3

for ((attempt = 1; attempt <= MAX_FOCUS_ATTEMPTS; attempt++)); do
  aerospace workspace -- "$VISIBLE_WORKSPACE"
  sleep 0.05

  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

  if [ "$FOCUSED_WORKSPACE" = "$VISIBLE_WORKSPACE" ]; then
    exit 0
  fi
done

printf 'Failed to focus monitor %s after %s attempts\n' \
  "$TARGET_MONITOR" \
  "$MAX_FOCUS_ATTEMPTS" >&2
exit 1
