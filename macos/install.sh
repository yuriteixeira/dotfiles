cd "$(dirname "$0")"

brew install \
  felixkratz/formulae/borders \
  gnu-sed \
  lsusb \
  zsh-completions

brew install --cask \
  aerospace \
  alfred \
  codex \
  font-jetbrains-mono-nerd-font \
  handbrake-app \
  karabiner-elements \
  libreoffice \
  localsend \
  macdown \
  qlmarkdown \
  tailscale-app

if [ -n "${WORKPLACE}" ]; then 
  brew install \
    atlassian/acli/acli \
    bazelisk \
    buildifier \
    cmake \
    coreutils \
    git-lfs

  brew install --cask \
    android-commandlinetools \
    android-platform-tools \
    android-studio \
    claude \
    claude-code \
    docker-desktop \
    gcloud-cli \
    intellij-idea
fi

