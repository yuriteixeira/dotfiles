# Profiling: Un-comment to enable (see https://xebia.com/profiling-zsh-shell-scripts/)
# zmodload zsh/zprof

### Zsh + OMZ
setopt SHARE_HISTORY # Share history between all sessions
setopt INC_APPEND_HISTORY # Append history to file immediately
setopt HIST_IGNORE_DUPS # Do not write duplicates
setopt HIST_IGNORE_SPACE # Do not write commands that begin with a space

plugins=(vi-mode fzf timer zsh-syntax-highlighting)

ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
DEFAULT_USER="$(whoami)"
PROMPT_EOL_MARK=""

source $ZSH/oh-my-zsh.sh

### My customizations
cwd="${${(%):-%N}:P:h}"

source "$cwd/env.sh"

for zshrc_file in "$cwd"/*.sh; do
  [ "$zshrc_file" != "$cwd/main.sh" ] && \
  [ "$zshrc_file" != "$cwd/env.sh" ] && \
  source "$zshrc_file"
done

[ -f $HOME/.zshrc_private ] && source $HOME/.zshrc_private

# https://unix.stackexchange.com/a/310553
setopt +o nomatch

# Profiling: Un-comment to enable
# zprof -c
# zprof

