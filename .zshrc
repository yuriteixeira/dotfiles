# Profiling: Un-comment to enable
# zmodload zsh/zprof

plugins=(common-aliases vi-mode)
 
cd "$( dirname "${BASH_SOURCE[0]}" )"
 
source $HOME/.zshrc_env
source $ZSH/oh-my-zsh.sh
source $HOME/.zshrc_helpers
source $HOME/.zshrc_vim
source $HOME/.zshrc_base16
source $HOME/.zshrc_fzf
source $HOME/.zshrc_autojump
source $HOME/.zshrc_spaceship
source $HOME/.zshrc_git
source $HOME/.zshrc_tmux

[ -f $HOME/.zshrc_private ] && source $HOME/.zshrc_private

export YVM_DIR="$HOME/.yvm"
[ -f $YVM_DIR/yvm.sh ] && source $YVM_DIR/yvm.sh

export NVM_DIR="$HOME/.nvm"
export NVM_BIN_DIR="/usr/local/opt/nvm"
[ -f $NVM_BIN_DIR/nvm.sh ] && source $NVM_BIN_DIR/nvm.sh
# [ -f $NVM_BIN_DIR/etc/bash_completion.d/nvm ] && source $NVM_BIN_DIR/etc/bash_completion.d/nvm

# [ rbenv > /dev/null ] && eval "$(rbenv init -)"

# Profiling: Un-comment to enable
# zprof -c 

