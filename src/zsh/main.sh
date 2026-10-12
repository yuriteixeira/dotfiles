# Profiling: Un-comment to enable (see https://xebia.com/profiling-zsh-shell-scripts/)
# zmodload zsh/zprof

### History
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt SHARE_HISTORY # Share history between all sessions
setopt INC_APPEND_HISTORY # Append history to file immediately
setopt HIST_IGNORE_DUPS # Do not write duplicates
setopt HIST_IGNORE_SPACE # Do not write commands that begin with a space

### Zsh plugins (no framework, replaces oh-my-zsh)
pluginsDir="$HOME/.local/share/zsh/plugins"

# Vi mode
# NOTE: zsh-vi-mode must be sourced BEFORE pure
ZVM_INIT_MODE=sourcing

[ -f "$pluginsDir/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ] && \
  source "$pluginsDir/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

# Syntax highlighting
[ -f "$pluginsDir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$pluginsDir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

### Prompt: pure (replaces the oh-my-zsh robbyrussell theme)
# zsh-async is a pure dependency (async git info, command timing)
source "$pluginsDir/zsh-async/async.zsh"

# No background `git fetch` on every prompt (pure does this by default,
# to show ⇡⇣ arrows). Set to 1 to enable.
export PURE_GIT_PULL=0

source "$pluginsDir/pure/pure.zsh"

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

