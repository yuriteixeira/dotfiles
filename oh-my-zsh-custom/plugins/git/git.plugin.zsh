### Loading original
plugin=git
source $ZSH/plugins/$plugin/$plugin.plugin.zsh

### Overrides
alias gs='gst'
alias gcfg="st $HOME/.gitconfig"
alias gsbfe="git submodule foreach"
alias gclean= "git checkout -- . && git reset --hard && git clean -df"
alias gcb="git checkout -b"

### Mine
alias gbc=$(current_branch)
alias gu='gup'
alias gra='grba'
alias grc='grbc'
alias gri='grbi'

export PREVIOUS_BRANCH=""

function c {
	echo ">>> Checking out $1"
	export PREVIOUS_BRANCH=$(current_branch)
	git checkout $1
}

function cb {
	echo ">>> Going back to $PREVIOUS_BRANCH"
	c $PREVIOUS_BRANCH
}