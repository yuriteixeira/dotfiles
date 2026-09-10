function tm {
    if [ -n "$1" ]; then
      tmux attach -t $1
    else
      tmux attach
    fi

    if [ $? -ne 0 ]; then
      tmux
    fi
}

alias tmk="tmux kill-session"

# Show current session name (useful to create git branches/worktrees)
alias tms="tmux display-message -p '#S'"

