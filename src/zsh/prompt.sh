# Right prompt: current time. Stays visible after a command runs
# (TRANSIENT_RPROMPT is off), so it shows the command start time.
# Pure clears RPROMPT in its setup, so this file must be sourced after pure.
unsetopt TRANSIENT_RPROMPT
RPROMPT='%F{8}[%D{%H:%M:%S}]%f'
