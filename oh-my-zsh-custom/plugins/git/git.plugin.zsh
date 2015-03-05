### Loading original
plugin=git
source $ZSH/plugins/$plugin/$plugin.plugin.zsh

### My personal stuff
alias gbc='git rev-parse --abbrev-ref HEAD'

### Overrides
alias gs='gst'
alias gcfg="ed $HOME/.gitconfig"
alias gsbfe="git submodule foreach"
alias gclean= "git reset --hard && git clean -df"
alias gcb="git checkout -b"