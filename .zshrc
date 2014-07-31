### Oh-my-zsh Initialization
ZSH=$HOME/.oh-my-zsh

# ZSH_THEME="ys"
DEFAULT_USER="$(whoami)"

export COMPOSER_HOME="$HOME/.composer"
export RVM_HOME=$HOME/.rvm/bin

export PATH="$COMPOSER_HOME/vendor/bin:$PATH"
export PATH="$RVM_PATH:$PATH"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

if [[ "$(uname)" == "Darwin" ]] then
	plugins=(common-aliases git brew composer dirhistory fasd npm osx sublime sudo symfony2 tmux vagrant web-search wd rvm zsh_reload)

	export EDITOR='subl -w'
	export PHP_VERSION='5.5'
	export PHP_VERSION_NO_DOTS='55'

	export GOPATH=`brew --prefix`/lib/go
	export PYTHONPATH=/usr/local/lib/python2.7/site-packages

	export PROJECTS_HOME=$HOME/Projects
	export DEV_HOME=$HOME/Dev
	export LA_HOME=$HOME/Library/LaunchAgents
	export LD_HOME=/Library/LaunchDaemons

	export PHP_HOME=`brew --prefix php$PHP_VERSION_NO_DOTS`
	export NODE_HOME=`brew --prefix node`
	export POWERLINE_HOME=$PYTHONPATH/powerline

	export NODE_PATH="/usr/local/lib/node_modules"
	export ANDROID_PLATFORMTOOLS_PATH="/Applications/Android Studio.app/sdk/platform-tools"
	export ANDROID_TOOLS_PATH="/Applications/Android Studio.app/sdk/tools"

	export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
	export PATH="$PHP_HOME/bin:$PATH"
	export PATH="$NODE_PATH:$PATH"
	export PATH="$ANDROID_TOOLS_PATH:$ANDROID_PLATFORMTOOLS_PATH:$PATH"
	export PATH="$PYTHONPATH:$PATH"

	# Ducknorris theme (Powerline)
	POWERLINE_DISABLE_RPROMPT="true"
	POWERLINE_FULL_CURRENT_PATH=""
	ZSH_THEME="ducknorris"
else
	plugins=(common-aliases git composer dirhistory fasd npm sudo symfony2 vagrant web-search wd zsh_reload)

	export EDITOR='vim'
	export PROJECTS_HOME=$HOME/src
fi

source $ZSH/oh-my-zsh.sh

### Working dirs
if [[ "$(uname)" == "Darwin" ]] then
	de && wd add! dev > /dev/null && \
	lb && wd add! lab > /dev/null && \
	pj && wd add! projects > /dev/null && \
	lah && wd add! launch-agents > /dev/null && \
	ldh && wd add! launch-daemons > /dev/null && \
	cd ~
else
	pj && wd add! projects > /dev/null && \
	cd ~
fi

### Additional Profiles
if [ -f ".zshrc_private" ]
then
    source .zshrc_private
fi