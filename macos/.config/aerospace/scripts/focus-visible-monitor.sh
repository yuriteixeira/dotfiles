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

aerospace workspace -- "$VISIBLE_WORKSPACE"
