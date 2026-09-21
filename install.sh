set -ex

cd "$(dirname "$0")"

### OS specific first

echo ">>> ALL: INSTALL..."
echo ""

[ "$(uname)" = "Linux" ] && \
  ./linux/install.sh

[ "$(uname)" = "Darwin" ] && \
  ./macos/install.sh

### Common stuff later

# Base16 themes
rm -rf ~/.config/base16-shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# Zsh & CLI Friends.
# A few are replacements, like these:
local -a cliReplacements=(
  zsh               # bash
  bat               # cat
  eza               # ls
  zoxide            # cd
  fd                # find
  dua-cli           # du/ncdu
  ripgrep           # grep
  neovim            # vim
  btop              # top/htop
  rsync             # cp
)

local -a cliEssential=(
  tmux              # terminal multiplexer
  tree-sitter       # neovim dep
  tree-sitter-cli   # neovim plugins dep
  git               # vcs
  git-delta         # diffs (outside git too)
  gitui             # git TUI
  fzf               # fuzzy search
  fastfetch         # quick info about the computer
  jq                # JSON parser
  wget              # downloader
  glow              # markdown preview
  ddgr              # duck, duck, go client
  yazi              # file explorer
  fnm               # node versions manager
  tuicr             # code reviews
)

cliTools="$cliReplacements[@] $cliEssential[@]"

# Other essentials that differ in name between OSs
local -a linuxCliTools=(
  $cliTools[@]
  7zip                    # file compression
  github-cli              # github cli
  ttf-jetbrains-mono-nerd # my fave coding font
  ccmux-bin               # agent sessions dash TUI + notifications
)

local -a macosCliTools=(
  $cliTools[@]
  sevenzip
  gh
  font-jetbrains-mono-nerd-font
  epilande/tap/ccmux
)

[ "$(uname)" = "Linux" ] && \
  sh -c "yay -S --noconfirm --needed $linuxCliTools" && \
  sudo chsh -s /usr/bin/zsh yuriteixeira

[ "$(uname)" = "Darwin" ] && \
  sh -c "brew install $macosCliTools"

# TODO: Get out of omz
rm -rf $HOME/.zshrc
rm -rf $HOME/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Zsh syntax highlight
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Fnm: Install latest --lts node version with corepack
fnm install --corepack-enabled --lts

# Pi.dev AI Harness
pnpm add -g --ignore-scripts @earendil-works/pi-coding-agent

# Nvim
rm -rf $HOME/.config/nvim
rm -rf $HOME/.local/state/nvim
rm -rf $HOME/.local/share/nvim
git clone git@github.com:yuriteixeira/kickstart-modular.nvim ~/.config/nvim

# GUI apps

[ "$(uname)" = "Linux" ] && \
  yay -S --noconfirm --needed alacritty obsidian obs-studio brave-bin

[ "$(uname)" = "Darwin" ] && \
    brew install --cask alacritty obsidian obs brave-browser

# Submodules
git submodule init
git submodule update --recursive
