# Replace the timer plugin display to avoid overwriting the right prompt.
function __timer_display_timer_precmd() {
  if [[ -n "${__timer_cmd_start_time}" ]]; then
    local cmd_end_time=$(__timer_current_time)
    local tdiff=$((cmd_end_time - __timer_cmd_start_time))
    unset __timer_cmd_start_time

    if [[ -z "${TIMER_THRESHOLD}" || ${tdiff} -ge "${TIMER_THRESHOLD}" ]]; then
      local last_cmd="${history[$((HISTCMD - 1))]%% *}"
      if [[ "$last_cmd" != clear ]]; then
        local duration=$(__timer_format_duration ${tdiff})
        print -r -- "$duration"
      fi
    fi
  fi
}
