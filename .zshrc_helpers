### Common

alias l="ls --group-directories-first"
alias ll="ls -l"
alias la="ls -lah"

alias rg="rg --hidden --glob '!node_modules' --glob '!.git'"
alias fd="fd --hidden --exclude node_modules --exclude .git --no-ignore"
alias glow='glow -s "$HOME/.config/glow/base16.json"'

# Fast-fetch
function ff {
  termColumns=$(tput cols)
  minColsForLogo=120

  if [ -n "$termColumns" ] && [ $termColumns -ge $minColsForLogo ];
  then
    fastfetch
  else
    fastfetch --logo none
  fi

  echo ""
}

# Hosts
alias hosts="sudo $EDITOR /etc/hosts"

# New file: Touch + Creates dir path (if needed)
function n {
  [ -z "$1" ] && echo "ERROR: Path, pls..." && return 1
  local filepath=$1
  local dirpath=$(dirname $filepath)
  [ ! -d "$dirpath" ] && mkdir -p $dirpath
  touch $filepath
  $EDITOR $filepath
}

