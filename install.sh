#!/bin/bash

### All dotfiles on home dir
find . -name ".*" -type f | grep -v ".gitignore" | grep -v ".swp" | awk -F './' '{print $2}' | xargs -I {} ln -sf $(pwd)/{} ~/

### Oh-my-zsh customizations
mkdir -p ~/.oh-my-zsh/custom/themes
find ./oh-my-zsh-custom/plugins -mindepth 1 -maxdepth 1 -type d | xargs -I {} ln -sf $(pwd)/{} ~/.oh-my-zsh/custom/plugins
find ./oh-my-zsh-custom/themes -mindepth 1 -maxdepth 1 -type f | xargs -I {} ln -sf $(pwd)/{} ~/.oh-my-zsh/custom/themes

echo "Dotfiles Installed!"