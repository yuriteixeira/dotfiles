# Profiling: Un-comment to enable (see https://xebia.com/profiling-zsh-shell-scripts/)
# zmodload zsh/zprof

plugins=(common-aliases vi-mode nvm fzf)
 
cd "$( dirname "${BASH_SOURCE[0]}" )"
 
source $HOME/.zshrc_env
source $HOME/.zshrc_fzf
source $ZSH/oh-my-zsh.sh
source $HOME/.zshrc_helpers
source $HOME/.zshrc_vim
source $HOME/.zshrc_base16
source $HOME/.zshrc_autojump
source $HOME/.zshrc_git
source $HOME/.zshrc_tmux

[ -f $HOME/.zshrc_private ] && source $HOME/.zshrc_private

# Profiling: Un-comment to enable
# zprof -c
# zprof 
