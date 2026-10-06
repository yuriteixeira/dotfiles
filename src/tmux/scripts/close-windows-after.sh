# Close windows with a greater index in the current session.
set -eu

target=${1:-${TMUX_PANE:-}}

if [ -z "$target" ]; then
    printf '%s\n' 'Run inside tmux or pass a target pane.' >&2
    exit 1
fi

context=$(tmux display-message -p -t "$target" '#{session_id}:#{window_index}')
session=${context%:*}
current_index=${context##*:}

# Save window IDs before closing any windows, since indexes can change.
windows=$(tmux list-windows -t "$session" -F '#{window_index}:#{window_id}')
for window in $windows; do
    index=${window%%:*}
    window_id=${window#*:}
    if [ "$index" -gt "$current_index" ]; then
        tmux kill-window -t "$window_id"
    fi
done
