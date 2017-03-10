### Oh-my-zsh Initialization
ZSH=$HOME/.oh-my-zsh

DEFAULT_USER="$(whoami)"

ZSH_THEME="avit"
PROMPT_EOL_MARK=""

plugins=(common-aliases git vi-mode)
export EDITOR='vim -p'

if [[ "$(uname)" == "Darwin" ]] then

	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8

	export PROJECTS_HOME=$HOME/Projects
	export DEV_HOME=$HOME/Dev

	export LA_HOME=$HOME/Library/LaunchAgents
	export LD_HOME=/Library/LaunchDaemons

	export JAVA_HOME="$(/usr/libexec/java_home)"

	export ANDROID_NDK=/usr/local/opt/android-ndk
	export ANDROID_SDK=/usr/local/opt/android-sdk
	export ANDROID_PLATFORMTOOLS_PATH="$ANDROID_SDK/platform-tools"
	export ANDROID_TOOLS_PATH="$ANDROID_SDK/tools"
	export ANDROID_HOME=$ANDROID_SDK

	export GOROOT=/usr/local/opt/go/libexec
	export MY_GOPATH=$DEV_HOME/workspaces/go
	export GOPATH=$MY_GOPATH

	export COMPOSER_HOME="$HOME/.composer"

	export MY_PATH="/usr/local/bin:/usr/local/sbin:$ANDROID_TOOLS_PATH:$ANDROID_PLATFORMTOOLS_PATH:$GOROOT/bin:$COMPOSER_HOME/vendor/bin:$PATH"
	export PATH=$MY_PATH

	#export NVM_DIR="$HOME/.nvm"
	#. "$(brew --prefix nvm)/nvm.sh"

else

	export PROJECTS_HOME=$HOME/src
fi

source $ZSH/oh-my-zsh.sh

### Additional Profiles
if [ -f ".zshrc_private" ]
then
    source .zshrc_private
fi

### Vim Mode for Terminal
bindkey -v
bindkey '^R' history-incremental-search-backward

### Base16 Colors 
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
