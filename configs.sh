set -x
originalDir=$PWD
cd "$(dirname "$0")"

mkdir -p $HOME/.config
mkdir -p $HOME/.local/share

[ "$(uname)" = "Linux" ] && \
  ./linux/configs.sh

[ "$(uname)" = "Darwin" ] && \
  ./macos/configs.sh

ln -sfn "$PWD/.zshrc_public" $HOME
ln -sfn "$PWD/.zshrc_base16" $HOME
ln -sfn "$PWD/.zshrc_env" $HOME
ln -sfn "$PWD/.zshrc_fzf" $HOME
ln -sfn "$PWD/.zshrc_git" $HOME
ln -sfn "$PWD/.zshrc_helpers" $HOME
rm -rf $HOME/.zshrc
echo 'source $HOME/.zshrc_public' >> $HOME/.zshrc

ln -sfn "$PWD/.zshrc_nvm" $HOME

ln -sfn "$PWD/.zshrc_tmux" $HOME
ln -sfn "$PWD/.zshrc_ssh" $HOME

ln -sfn "$PWD/.base16_favorites" $HOME
ln -sfn "$PWD/.base16_theme" $HOME/.config/base16-shell/scripts/base16-yuri.sh

ln -sfn "$PWD/.tmux.conf" $HOME
ln -sfn "$PWD/.tmux.settings.conf" $HOME
ln -sfn "$PWD/.tmux.vi.conf" $HOME
ln -sfn "$PWD/.tmux.shortcuts.conf" $HOME
ln -sfn "$PWD/.tmux.styles.conf" $HOME
ln -sfn "$PWD/.tmux.plugins.conf" $HOME

ln -sfn "$PWD/.gitconfig" $HOME
ln -sfn "$PWD/.gitignore_global" $HOME
ln -sfn "$PWD/.config/gitui/" $HOME/.config

ln -sfn "$PWD/.config/bat/" $HOME/.config
ln -sfn "$PWD/.config/glow/" $HOME/.config

if [ "$(uname)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Preferences/glow"
  ln -sfn "$PWD/.config/glow/glow.yml" "$HOME/Library/Preferences/glow/glow.yml"
  ln -sfn "$PWD/.config/glow/base16.json" "$HOME/Library/Preferences/glow/base16.json"
fi

# AI agent configuration
ln -sfn "$PWD/.pi/" $HOME/.pi

ln -sfn "$PWD/resources/wallpapers" $HOME/Wallpapers

# TODO: Candidates to move to a private file (eg: work-notebook.sh or something)
# ln -sfn "$PWD/.huskyrc" $HOME
# ln -sfn "$PWD/.ideavimrc" $HOME

# See: https://unencumberedbyfacts.com/2016/01/04/psql-vim-happy-face/
# ln -sfn "$PWD/.inputrc" $HOME

cd $originalDir
set +x
