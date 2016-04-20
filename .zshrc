### Oh-my-zsh Initialization
ZSH=$HOME/.oh-my-zsh

DEFAULT_USER="$(whoami)"

ZSH_THEME="ys"
PROMPT_EOL_MARK=""

if [[ "$(uname)" == "Darwin" ]] then

	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8

	plugins=(common-aliases git dirhistory sudo symfony2 tmux osx brew)

	export EDITOR='atom'

	export PROJECTS_HOME=$HOME/Projects
	export DEV_HOME=$HOME/Dev

	export LA_HOME=$HOME/Library/LaunchAgents
	export LD_HOME=/Library/LaunchDaemons

	export JAVA_HOME="$(/usr/libexec/java_home)"

	export ANDROID_SDK_ROOT="$HOME/Dev/workspaces/android-sdk-macosx"
	export ANDROID_PLATFORMTOOLS_PATH="$ANDROID_SDK_ROOT/platform-tools"
	export ANDROID_TOOLS_PATH="$ANDROID_SDK_ROOT/tools"

	export GOROOT=/usr/local/opt/go/libexec
	export MY_GOPATH=$DEV_HOME/workspaces/go
	export GOPATH=$MY_GOPATH

	export COMPOSER_HOME="$HOME/.composer"

	export MY_PATH="/usr/local/bin:/usr/local/sbin:$ANDROID_TOOLS_PATH:$ANDROID_PLATFORMTOOLS_PATH:$GOROOT/bin:$COMPOSER_HOME/vendor/bin:$PATH"
	export PATH=$MY_PATH

else

	plugins=(common-aliases git dirhistory sudo symfony2)

	export EDITOR='vim'
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
