set -x
originalDir=$PWD
cd "$(dirname "$0")"

mkdir -p $HOME/.config
mkdir -p $HOME/.local/share

[ "$(uname)" = "Linux" ] && \
  ./linux/configs.sh

[ "$(uname)" = "Darwin" ] && \
  ./macos/configs.sh

ln -sf "$PWD/.zshrc_public" $HOME
ln -sf "$PWD/.zshrc_base16" $HOME
ln -sf "$PWD/.zshrc_env" $HOME
ln -sf "$PWD/.zshrc_fzf" $HOME
ln -sf "$PWD/.zshrc_git" $HOME
ln -sf "$PWD/.zshrc_helpers" $HOME
rm -rf $HOME/.zshrc
echo 'source $HOME/.zshrc_public' >> $HOME/.zshrc

ln -sf "$PWD/.zshrc_nvm" $HOME

ln -sf "$PWD/.zshrc_tmux" $HOME
ln -sf "$PWD/.zshrc_ssh" $HOME

ln -sf "$PWD/.base16_favorites" $HOME
ln -sf "$PWD/.base16_theme" $HOME/.config/base16-shell/scripts/base16-yuri.sh

ln -sf "$PWD/.tmux.conf" $HOME
ln -sf "$PWD/.tmux.settings.conf" $HOME
ln -sf "$PWD/.tmux.vi.conf" $HOME
ln -sf "$PWD/.tmux.shortcuts.conf" $HOME
ln -sf "$PWD/.tmux.styles.conf" $HOME
ln -sf "$PWD/.tmux.plugins.conf" $HOME

ln -sf "$PWD/.gitconfig" $HOME
ln -sf "$PWD/.gitignore_global" $HOME
ln -sf "$PWD/.config/gitui/" $HOME/.config

ln -sf "$PWD/.config/bat/" $HOME/.config
ln -sf "$PWD/.config/glow/" $HOME/.config

if [ "$(uname)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Preferences/glow"
  ln -sf "$PWD/.config/glow/glow.yml" "$HOME/Library/Preferences/glow/glow.yml"
  ln -sf "$PWD/.config/glow/base16.json" "$HOME/Library/Preferences/glow/base16.json"
fi

# AI agent configuration
ln -sf "$PWD/.pi/" $HOME/.pi

ln -sf "$PWD/resources/wallpapers" $HOME/Wallpapers

# TODO: Candidates to move to a private file (eg: work-notebook.sh or something)
# ln -sf "$PWD/.huskyrc" $HOME
# ln -sf "$PWD/.ideavimrc" $HOME

# See: https://unencumberedbyfacts.com/2016/01/04/psql-vim-happy-face/
# ln -sf "$PWD/.inputrc" $HOME

cd $originalDir
set +x
