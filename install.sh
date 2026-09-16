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

# Zsh & CLI Friends. A few are replacements, like these:
local -a cliReplacements=(
  zsh # bash
  bat # cat
  eza # ls
  zoxide # cd
  fd # find
  dua-cli # du/ncdu
  ripgrep # grep
  neovim # vim
  btop # top/htop
  rsync # cp
)

local -a cliEssential=(
  tmux
  tree-sitter
  tree-sitter-cli
  git
  git-delta
  gitui
  fzf
  fastfetch
  jq
  wget
  glow
  ddgr
  yazi
)

cliTools="$cliReplacements[@] $cliEssential[@]"

linuxCliTools="$cliTools 7zip github-cli ttf-jetbrains-mono-nerd"
macosCliTools="$cliTools sevenzip gh font-jetbrains-mono-nerd-font"

[ "$(uname)" = "Linux" ] && \
  sh -c "yay -S --noconfirm --needed $linuxCliTools" && \
  sudo chsh -s /usr/bin/zsh yuriteixeira

[ "$(uname)" = "Darwin" ] && \
  sh -c "brew install $macosCliTools"

rm -rf $HOME/.zshrc
rm -rf $HOME/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Zsh syntax highlight
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Nvm: Check latest version and change it below https://github.com/nvm-sh/nvm/releases
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'

# TODO: Test this out, I have the impression it didn't work
nvm install --lts
corepack enable
pnpm --version

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
