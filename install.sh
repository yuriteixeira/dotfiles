# env /bin/bash

### Dotfiles
mkdir -p $HOME/.config

ln -sf "$PWD/.config/bat" $HOME/.config
ln -sf "$PWD/.config/karabiner" $HOME/.config
ln -sf "$PWD/.config/nvim" $HOME/.config
ln -sf "$PWD/.config/vscode" $HOME/.config
ln -sf "$PWD/.config/yarn" $HOME/.config

ln -sf "$PWD/.ctags.d" $HOME

ln -sf "$PWD/.vim" $HOME

ln -sf "$PWD/.base16_favorites" $HOME

ln -sf "$PWD/.gitconfig" $HOME
ln -sf "$PWD/.gitignore_global" $HOME

ln -sf "$PWD/.ideavimrc" $HOME

ln -sf "$PWD/.tmux.conf" $HOME
ln -sf "$PWD/.tmux.plugins.conf" $HOME
ln -sf "$PWD/.tmux.settings.conf" $HOME
ln -sf "$PWD/.tmux.shortcuts.conf" $HOME
ln -sf "$PWD/.tmux.styles.conf" $HOME
ln -sf "$PWD/.tmux.vi.conf" $HOME

ln -sf "$PWD/.vim" $HOME
ln -sf "$PWD/.vimrc_colors" $HOME
ln -sf "$PWD/.vimrc_plugins" $HOME
ln -sf "$PWD/.vimrc_plugins_semibasics" $HOME
ln -sf "$PWD/.vimrc_settings" $HOME
ln -sf "$PWD/.vimrc_shortcuts" $HOME

ln -sf "$PWD/.zshrc" $HOME
ln -sf "$PWD/.zshrc_autojump" $HOME
ln -sf "$PWD/.zshrc_base16" $HOME
ln -sf "$PWD/.zshrc_env" $HOME
ln -sf "$PWD/.zshrc_fzf" $HOME
ln -sf "$PWD/.zshrc_git" $HOME
ln -sf "$PWD/.zshrc_helpers" $HOME
ln -sf "$PWD/.zshrc_nvm" $HOME
ln -sf "$PWD/.zshrc_tmux" $HOME
ln -sf "$PWD/.zshrc_vim" $HOME


### Configs
defaults write -g ApplePressAndHoldEnabled -bool false 