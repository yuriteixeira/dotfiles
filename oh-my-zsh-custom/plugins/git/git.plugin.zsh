### Loading original
plugin=git
source $ZSH/plugins/$plugin/$plugin.plugin.zsh

### Overrides
alias gs='gst'
alias gcfg="ed $HOME/.gitconfig"
alias gsbfe="git submodule foreach"
alias gclean='git reset --hard && git clean -df'