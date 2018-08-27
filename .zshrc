cd "$( dirname "${BASH_SOURCE[0]}" )"

plugins=(common-aliases git vi-mode)

source ~/.zshrc_env
source $ZSH/oh-my-zsh.sh

source ~/.zshrc_helpers
source ~/.zshrc_vim
source ~/.zshrc_base16
source ~/.zshrc_fzf
source ~/.zshrc_autojump
source ~/.zshrc_spaceship
source ~/.zshrc_git
source ~/.zshrc_tmux

[ -f ~/.zshrc_private ] && source ~/.zshrc_private
