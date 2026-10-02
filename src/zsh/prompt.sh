# Keep the command start time visible on the right after execution.
unsetopt TRANSIENT_RPROMPT
RPROMPT='%F{8}[%D{%H:%M:%S}]%f'

function refresh_command_start_time() {
  zle reset-prompt
}

autoload -Uz add-zle-hook-widget
add-zle-hook-widget line-finish refresh_command_start_time
