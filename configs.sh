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
ln -sf "$PWD/src/zsh/main.sh" "$HOME/.zshrc_public"

ln -sf "$PWD/.base16_favorites" $HOME
ln -sf "$PWD/.base16_theme" $HOME/.config/base16-shell/scripts/base16-yuri.sh

ln -sf "$PWD/src/tmux/main.conf" "$HOME/.tmux.conf"

ln -sf "$PWD/.gitconfig" $HOME
ln -sf "$PWD/.gitignore_global" $HOME

# TODO: Why not symlink .config fully?
ln -sf "$PWD/.config/gitui/" $HOME/.config
ln -sf "$PWD/.config/bat/" $HOME/.config
ln -sf "$PWD/.config/glow/" $HOME/.config
ln -sf "$PWD/.config/yazi/" $HOME/.config
ln -sf "$PWD/.config/nchat/" $HOME/.config

duaConfigTarget="$HOME/.config"
[ "$(uname)" = "Darwin" ] && duaConfigTarget="$HOME/Library/Application\ Support"
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
