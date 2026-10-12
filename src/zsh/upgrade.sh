### Tooling upgrade

function upgrade {
    if [[ "$(uname)" == "Darwin" ]] then
        echo ""
        echo ">>> Brew / Brew Cask"
        brew update
        brew upgrade
        brew upgrade --casks --greedy
        brew cleanup
    fi

    if [[ "$(uname)" == "Linux" ]] then
        echo ""
        echo ">>> Pacman / AUR"
        yay -Suy
    fi

    echo ""
    echo ">>> PNPM (Global)"
    pnpm -g update --latest

    echo ""
    echo ">>> Tmux Plugins"
    ~/.tmux/plugins/tpm/bin/update_plugins all

    echo ""
    echo ">>> Pi + Extensions"
    pi update --all

    echo ""
    echo ">>> Docker cleanup"
    docker system prune -f

    if command -v gcloud &> /dev/null; then
        echo ""
        echo ">>> Google Cloud CLI"
        yes | gcloud components update
    fi

    echo ""
    echo ">>> Other updates"
    git -C ~/.config/base16-shell pull

    echo ""
    echo ">>> Zsh plugins"
    git -C ~/.local/share/zsh/plugins/zsh-vi-mode pull
    git -C ~/.local/share/zsh/plugins/zsh-syntax-highlighting pull
    git -C ~/.local/share/zsh/plugins/pure pull
    git -C ~/.local/share/zsh/plugins/zsh-async pull
}
