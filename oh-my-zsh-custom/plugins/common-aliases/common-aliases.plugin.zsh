### Loading original
plugin=common-aliases
source $ZSH/plugins/$plugin/$plugin.plugin.zsh

### Overrides

# Common commands improvement
alias a="alias"
alias p="ps aux"
alias e=$EDITOR
alias k="pkill -f"

# Open profile with editor
alias pf="$EDITOR \
~/.zshrc \
~/.zshrc_private \
~/.oh-my-zsh/custom/plugins/common-aliases/common-aliases.plugin.zsh \
~/.tmux.conf \
~/.vimrc"

alias rpf="source ~/.zshrc"

# Hosts
alias hosts="sudo $EDITOR /etc/hosts"

# XDebug
function xdebug-start {
	xdebug_site=$1
	xdebug_host=$2
	xdebug_port=$3
	xdebug_idekey=$4

	if [[ -z $xdebug_site ]] then
		xdebug_site="site.dev"
	fi

	if [[ -z $xdebug_host ]] then
		xdebug_host="127.0.0.1"
	fi

	if [[ -z $xdebug_port ]] then
		xdebug_port="9000"
	fi

	if [[ -z $xdebug_idekey ]] then
		xdebug_idekey="PHPSTORM"
	fi

	export PHP_IDE_CONFIG="serverName=$xdebug_site"
	export XDEBUG_CONFIG="remote_host=$xdebug_host remote_port=$xdebug_port idekey=$xdebug_idekey"
}

alias xdebug-stop="unset XDEBUG_CONFIG && unset PHP_IDE_CONFIG"

# Important directories (aliases and working directories)
alias pj="cd $PROJECTS_HOME"

if [[ "$(uname)" == "Darwin" ]] then
	alias de="cd $DEV_HOME"
	alias lb="cd $DEV_HOME/lab"
	alias lah="cd $LA_HOME"
	alias ldh="cd $LD_HOME"
fi

alias yh="cd ~/Dropbox/Workspaces/Yuri/home"

# Brew
alias b=brew
alias bi="brew install"
alias br="brew remove"
alias bs="brew search"

# Docker
alias d=docker
alias di='docker images'
alias dm="docker-machine"
alias dc="docker-compose"
alias denv='eval $(docker-machine env)'
alias drma='docker rm -f $(docker ps -a -q)'
alias drmia='docker rmi $(docker images | grep "^<none>" | awk "{print $3}")'

# Go
alias mygo="export GOPATH=$MY_GOPATH"
alias mypath="export PATH=$MY_PATH"

function gohome {
	mygo
	mypath
	export GOPATH="$(pwd)/.vendor:$(pwd)"
	export PATH="$(pwd)/.vendor/bin:$(pwd)/bin:$PATH"
}

# Git Credentials
function gitcred-personal {
	git config user.name "Yuri Teixeira"
	git config user.email "oyuriteixeira@gmail.com"
}

# Tmux
function tm {
    tmux attach

    if [ $? -ne 0 ]; then
      tmux
    fi
}

alias tmk="tmux kill-session"
alias tma="tmux attach"
alias tml="tmux list-sessions"
