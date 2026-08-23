if [[ -z "${TMUX}" && -z "${WAYLAND_DISPLAY:-}" && "${XDG_VTNR:-}" == 1 ]]; then
  "$HOME/.local/bin/one"
fi
