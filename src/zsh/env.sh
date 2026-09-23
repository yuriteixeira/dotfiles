### Env vars

export DOTFILES=$HOME/Workspaces/github/yuriteixeira/dotfiles

export EDITOR='nvim'
export MANPAGER='nvim +Man!'
export NODE_OPTIONS="--dns-result-order=ipv4first"

export TIMEFMT='%J   %U  user %S system %P cpu %*E total'$'\n'\
'avg shared (code):         %X KB'$'\n'\
'avg unshared (data/stack): %D KB'$'\n'\
'total (sum):               %K KB'$'\n'\
'max memory:                %M MB'$'\n'\
'page faults from disk:     %F'$'\n'\
'other page faults:         %R'
export TIMER_FORMAT='\n\n⏱  %d'


### Paths

function addToPath {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$PATH:$1" ;;
  esac

  export PATH
}

addToPath "$HOME/.local/bin"
addToPath "$HOME/.cargo/bin"
addToPath "$HOME/.bun/bin"

export PNPM_HOME="$HOME/.local/share/pnpm"
addToPath "$PNPM_HOME"
addToPath "$PNPM_HOME/bin"
addToPath "$HOME/.pi/agent/npm/node_modules/.bin"

if [[ "$(uname)" == "Linux" ]] then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
  export XDG_SCREENSHOTS_DIR="$HOME/Screenshots"

  export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

  export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"

  export ANDROID_COMPILE_SDK=35
  export ANDROID_BUILD_TOOLS_VERSION=35.0.0
  export ANDROID_HOME="$HOME/Workspaces/android/sdk"
  export ANDROID_BIN="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"

  addToPath $ANDROID_BIN

  function distrobox_prompt_info() {
    if [[ -n "$CONTAINER_ID" ]]; then
      echo "%{$fg[magenta]%}📦 [$CONTAINER_ID]%{$reset_color%} "
    fi
  }

  PROMPT='$(distrobox_prompt_info)'$PROMPT
fi

if [[ "$(uname)" == "Darwin" ]] then
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8

    export LA_HOME=$HOME/Library/LaunchAgents
    export LD_HOME=/Library/LaunchDaemons

    export GNU_PATH="/usr/local/opt/gnu-sed/libexec/gnubin"
    addToPath $GNU_PATH

    if command -v brew &> /dev/null; then
        export HOMEBREW_NO_VERIFY_ATTESTATIONS=1
        export BREW_PREFIX=$(brew --prefix)
        export HOMEBREW_BIN_PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin"
        addToPath $HOMEBREW_BIN_PATH
    fi
fi


### Initializations

# If we are inside tmux, but the actual physical terminal hosting tmux is a Linux TTY
if [ -n "$TMUX" ] && [ "$TERM" = "linux" ]; then
  unset COLORTERM
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
fi

if command -v eza &> /dev/null; then
  alias ls='eza --icons=auto'
  alias l="ls -l -X"
else
  alias ls="ls --color"
fi

if command -v fnm &> /dev/null; then
  [ -z "$FNM_DIR" ] && eval "$(fnm env --use-on-cd --version-file-strategy=recursive --resolve-engines=false --shell zsh)"
fi

if [ -n "$BREW_PREFIX" ]; then
  FPATH=$BREW_PREFIX/share/zsh-completions:$FPATH
fi

autoload -Uz compinit
compinit

# Also, run this if necessary
# rm -f ~/.zcompdump
# compinit
# chmod go-w '/opt/homebrew/share'
# chmod -R go-w '/opt/homebrew/share/zsh'
