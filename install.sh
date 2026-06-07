set -ex

cd "$(dirname "$0")"

### REQUIREMENTS

echo ">>> ALL: INSTALL..."
echo ""

[ "$(uname)" = "Linux" ] && \
  ./linux/install.sh

[ "$(uname)" = "Darwin" ] && \
  ./macos/install.sh

# Base16 Themes
rm -rf ~/.config/base16-shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# Zsh & CLI Friends. A few are replacements, like these:
#
# btop -> top/htop
# dust, ncdu & btdu -> du
# eza -> ls
# neovim -> vim 
# ripgrep -> grep
# zoxide -> cd + autojump
# zsh -> bash
# rsync -> cp
# bat -> cat
# fd -> find
cliTools='zsh tmux neovim tree-sitter tree-sitter-cli git git-delta gitui fzf eza zoxide ripgrep rsync btop dust ncdu fastfetch keychain bat jq fd wget glow'

[ "$(uname)" = "Linux" ] && \
  sh -c "yay -S --noconfirm --needed $cliTools github-cli" && \
  sudo chsh -s /usr/bin/zsh yuriteixeira

[ "$(uname)" = "Darwin" ] && \
  sh -c "brew install $cliTools gh"

rm -rf $HOME/.zshrc
rm -rf $HOME/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Nvm (Node)
# IMPORTANT: Check latest version and change it below https://github.com/nvm-sh/nvm/releases
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'
# TODO: Test this out, I have the impression it didn't work
nvm install --lts
corepack enable
pnpm --version

# Nvim + Nerd Font (needed to render icons correctly)
[ "$(uname)" = "Darwin" ] && \
  brew install --cask font-jetbrains-mono-nerd-font

[ "$(uname)" = "Linux" ] && \
  yay -S --noconfirm --needed ttf-jetbrains-mono-nerd

rm -rf $HOME/.config/nvim
rm -rf $HOME/.local/state/nvim
rm -rf $HOME/.local/share/nvim
git clone git@github.com:yuriteixeira/kickstart-modular.nvim ~/.config/nvim

### GUI APPS
[ "$(uname)" = "Linux" ] && \
  yay -S --noconfirm --needed alacritty obsidian obs-studio brave-bin

[ "$(uname)" = "Darwin" ] && \
    brew install --cask alacritty obsidian obs brave-browser

