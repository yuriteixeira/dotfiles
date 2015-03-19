### Oh-my-zsh Initialization
ZSH=$HOME/.oh-my-zsh

DEFAULT_USER="$(whoami)"

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Docker
export DOCKER_TLS_VERIFY=1
export DOCKER_HOST=tcp://192.168.59.103:2376
export DOCKER_CERT_PATH=/Users/yuriteixeira/.boot2docker/certs/boot2docker-vm

ZSH_THEME="ys"
ZSH_DEFAULT_PLUGINS=(common-aliases git dirhistory sudo symfony2)

if [[ "$(uname)" == "Darwin" ]] then

	ZSH_MAC_PLUGINS=(tmux osx sublime brew)
	plugins=("${ZSH_DEFAULT_PLUGINS[@]} ${ZSH_MAC_PLUGINS[@]}")
	export EDITOR='st'

	export PROJECTS_HOME=$HOME/Projects
	export DEV_HOME=$HOME/Dev
	export LA_HOME=$HOME/Library/LaunchAgents
	export LD_HOME=/Library/LaunchDaemons

	export ANDROID_PLATFORMTOOLS_PATH="/Applications/Android Studio.app/sdk/platform-tools"
	export ANDROID_TOOLS_PATH="/Applications/Android Studio.app/sdk/tools"

	export GOROOT=/usr/local/opt/go/libexec/bin
	export GOPATH=$DEV_HOME/workspaces/go

	export COMPOSER_HOME="$HOME/.composer"

	export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
	export PATH="$ANDROID_TOOLS_PATH:$ANDROID_PLATFORMTOOLS_PATH:$GOROOT:$COMPOSER_HOME/vendor/bin:$PATH"

else

	plugins=$ZSH_DEFAULT_PLUGINS
	
	export EDITOR='vim'
	export PROJECTS_HOME=$HOME/src
fi

source $ZSH/oh-my-zsh.sh

### Additional Profiles
if [ -f ".zshrc_private" ]
then
    source .zshrc_private
fi

### Notes

# Plugins to take a look: fasd