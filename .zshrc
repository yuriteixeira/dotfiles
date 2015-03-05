
### Oh-my-zsh Initialization
ZSH=$HOME/.oh-my-zsh

DEFAULT_USER="$(whoami)"

export COMPOSER_HOME="$HOME/.composer"

export PATH="$COMPOSER_HOME/vendor/bin:$PATH"
export PATH="$RVM_PATH:$PATH"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export DOCKER_TLS_VERIFY=1
export DOCKER_HOST=tcp://192.168.59.103:2376
export DOCKER_CERT_PATH=/Users/yuriteixeira/.boot2docker/certs/boot2docker-vm

# Plugins to take a look: fasd

if [[ "$(uname)" == "Darwin" ]] then

	plugins=(common-aliases git brew dirhistory osx sublime sudo tmux zsh_reload)

	export EDITOR='vim'

	export PROJECTS_HOME=$HOME/Projects
	export DEV_HOME=$HOME/Dev
	export LA_HOME=$HOME/Library/LaunchAgents
	export LD_HOME=/Library/LaunchDaemons

	export ANDROID_PLATFORMTOOLS_PATH="/Applications/Android Studio.app/sdk/platform-tools"
	export ANDROID_TOOLS_PATH="/Applications/Android Studio.app/sdk/tools"

	export GOPATH=$DEV_HOME/workspaces/go

	export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
	export PATH="$ANDROID_TOOLS_PATH:$ANDROID_PLATFORMTOOLS_PATH:$PATH"

	ZSH_THEME="ys"
else

	plugins=(common-aliases git dirhistory sudo symfony2 zsh_reload)

	ZSH_THEME="ys"
	export EDITOR='vim'
	export PROJECTS_HOME=$HOME/src
fi

source $ZSH/oh-my-zsh.sh

### Additional Profiles
if [ -f ".zshrc_private" ]
then
    source .zshrc_private
fi