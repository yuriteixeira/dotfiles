set -x
originalDir=$PWD
cd "$(dirname "$0")"

mkdir -p $HOME/.config
mkdir -p $HOME/.local/share

[ "$(uname)" = "Linux" ] && \
  ./linux/configs.sh

[ "$(uname)" = "Darwin" ] && \
  ./macos/configs.sh

rm -rf $HOME/.zshrc
echo 'source $HOME/.zshrc_public' >> $HOME/.zshrc
ln -sf "$PWD/.zshrc_public" $HOME

# TODO: Investigate moving to those to subfolders (eg: .zshrc_base16 becomes zsh/base16.sh), so no need to track symlinks
ln -sf "$PWD/.zshrc_base16" $HOME
ln -sf "$PWD/.zshrc_env" $HOME
ln -sf "$PWD/.zshrc_fzf" $HOME
ln -sf "$PWD/.zshrc_git" $HOME
ln -sf "$PWD/.zshrc_helpers" $HOME
ln -sf "$PWD/.zshrc_tmux" $HOME
ln -sf "$PWD/.zshrc_ssh" $HOME
ln -sf "$PWD/.zshrc_ai" $HOME
ln -sf "$PWD/.zshrc_upgrade" $HOME
ln -sf "$PWD/.zshrc_vendor_wrappers" $HOME

ln -sf "$PWD/.base16_favorites" $HOME
ln -sf "$PWD/.base16_theme" $HOME/.config/base16-shell/scripts/base16-yuri.sh

ln -sf "$PWD/.tmux.conf" $HOME
ln -sf "$PWD/.tmux.settings.conf" $HOME
ln -sf "$PWD/.tmux.vi.conf" $HOME
ln -sf "$PWD/.tmux.commands.conf" $HOME
ln -sf "$PWD/.tmux.shortcuts.conf" $HOME
ln -sf "$PWD/.tmux.styles.conf" $HOME
ln -sf "$PWD/.tmux.plugins.conf" $HOME

ln -sf "$PWD/.gitconfig" $HOME
ln -sf "$PWD/.gitignore_global" $HOME

ln -sf "$PWD/.config/gitui/" $HOME/.config
ln -sf "$PWD/.config/bat/" $HOME/.config
ln -sf "$PWD/.config/glow/" $HOME/.config
ln -sf "$PWD/.config/yazi/" $HOME/.config

[ "$(uname)" = "Darwin" ] && duaConfigTarget="$HOME/Library/Application\ Support"
[ "$(uname)" = "Linux" ] && duaConfigTarget="$HOME/.config"
ln -sf "$PWD/.config/dua-cli" $duaConfigTarget

# AI agent configuration
ln -sf "$PWD/.pi/" $HOME/.pi

# Submodules
ln -sf "$PWD/submodules/fzf-git" $HOME/.local/share

# Wallpapers
ln -sf "$PWD/resources/wallpapers" $HOME/Wallpapers

# See: https://unencumberedbyfacts.com/2016/01/04/psql-vim-happy-face/
# ln -sf "$PWD/.inputrc" $HOME

cd $originalDir
set +x
