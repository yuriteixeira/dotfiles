### Loading original
plugin=common-aliases
source $ZSH/plugins/$plugin/$plugin.plugin.zsh

### Overrides 

# Common commands improvement
alias psgrep="ps aux | grep"
alias cl="clear"

# Open profile with editor
alias pf="st ~/.zshrc ~/.zshrc_private"

# Hosts 
alias hosts="sudo ed /etc/hosts"

# PHP
alias xdebug-start='export XDEBUG_CONFIG="idekey=PHPSTORM remote_host=127.0.0.1 remote_port=9000"'
alias xdebug-stop="unset XDEBUG_CONFIG"

function xdebug-target-site {
	SITENAME=$1
	export PHP_IDE_CONFIG="serverName=$SITENAME"
}

# Important directories (aliases and working directories)
alias pj="cd $PROJECTS_HOME"

if [[ "$(uname)" == "Darwin" ]] then
	alias de="cd $DEV_HOME"
	alias lb="cd $DEV_HOME/lab"
	alias lah="cd $LA_HOME"
	alias ldh="cd $LD_HOME"
fi