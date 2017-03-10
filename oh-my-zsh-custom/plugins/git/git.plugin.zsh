### Loading original
plugin=git
source $ZSH/plugins/$plugin/$plugin.plugin.zsh

### Overrides
alias gs='gst'
alias gcfg="$EDITOR $HOME/.gitconfig"
alias gsbfe="git submodule foreach"
alias gclean="git checkout -- . && git reset --hard && git clean -df"
alias gcb="git checkout -b"
alias gd="git diff HEAD"

### Mine
alias gbc=$(current_branch)
alias gu='gup'
alias gra='grba'
alias grc='grbc'
alias gri='grbi'
alias gdc='gd --cached'

# Branch navigation
export PREVIOUS_BRANCH=""

function c {
	echo ">>> Checking out $1"
	export PREVIOUS_BRANCH=$(current_branch)
	git checkout $1
}

function cl {
    if [ ! -z "$PREVIOUS_BRANCH"]; then
	    echo ">>> Last branch: $PREVIOUS_BRANCH"
    fi
}

function cb {
	echo ">>> Going back to $PREVIOUS_BRANCH"
	c $PREVIOUS_BRANCH
}

# Git Credentials
function gitcred-personal {
	git config user.name "Yuri Teixeira"
	git config user.email "oyuriteixeira@gmail.com"
}
