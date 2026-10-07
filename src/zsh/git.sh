### Git

## fzf-git
export FZF_GIT_PAGER='delta --paging=never'
export FZF_GIT_FZF_CUSTOM_ARGS='--no-height --no-tmux'
export FZF_GIT_KEY_ADD="ctrl-s"
export FZF_GIT_KEY_TOGGLE_PREVIEW="ctrl-p"
export FZF_GIT_KEY_OPEN_EDITOR="ctrl-e"

[ -f $HOME/.local/share/fzf-git/fzf-git.sh ] && source $HOME/.local/share/fzf-git/fzf-git.sh

## Wrappers
alias g="git"

function gitcred {
    if [ -z "${GIT_USER_NAME}" ] || [ -z "${GIT_USER_EMAIL}" ];
    then
        echo "Failed: you must set the GIT_USER_NAME & GIT_USER_EMAIL env vars"
        return 1;
    fi

    git config user.name "${GIT_USER_NAME}"
    git config user.email "${GIT_USER_EMAIL}"

    echo ">>> Success! ${GIT_USER_NAME} <${GIT_USER_EMAIL}>"
}

alias gs="_fzf_git_unstaged_files"
alias gsa="gs | xargs | git add"
alias gl="_fzf_git_hashes"

alias gd="DELTA_FEATURES=+side-by-side g d"
alias gdc="DELTA_FEATURES=+side-by-side g dc"

# diff: for merges, so I just see what matters in the diff
alias gdm='git diff "$(git merge-tree --write-tree -Xours HEAD^1 HEAD^2 | head -1)" HEAD'

# diff: stats of total delta of lines added/removed
function gds = {
    echo ">>> File stats:"
    echo ""
    git diff --name-status --diff-filter=AMD "$@" | awk '{count[$1]++} END {print "Added:", count["A"]+0; print "Modified:", count["M"]+0; print "Deleted:", count["D"]+0}'
    echo ""
    echo ">>> Line stats:"
    echo ""
    git diff --numstat --format="" "$@" | awk '{added+=$1; deleted+=$2} END {printf "Total Delta: %d (+%d, -%d)\n", added-deleted, added, deleted}'
}

# worktree: list
alias gw="git worktree list"

# worktree: Add a worktree on parent dir
function gwa {
    local friendlyName=$1
    local gitRef=$2
    local worktreeDir=''

    currentDir=$(echo $PWD | rev | cut -d'/' -f1 | rev)
    worktreeDir=$currentDir-$friendlyName

    git fetch origin
    git worktree add -f ../$worktreeDir $gitRef

    echo '>>> Done, taking you to the directory of the new worktree'
    cd ../$worktreeDir
}
