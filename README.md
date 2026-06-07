# Dotfiles

My Linux/macOS dotfiles and setup scripts.

## Objectives & Principles

See [OBJECTIVES_AND_PRINCIPLES.md](./OBJECTIVES_AND_PRINCIPLES.md).

## What this repo covers

- zsh + Oh My Zsh + base16
- tmux
- Neovim (`kickstart-modular.nvim`)
- Alacritty
- Sway (Linux) / Aerospace (macOS)
- Caps Lock remaps (`Esc` tap, `hjkl` arrows when held)
- Common CLI tools: git, fzf, eza, zoxide, ripgrep, bat, fd, btop, etc.

## Layout

- `install.sh` — top-level installer; dispatches to `linux/` or `macos/`
- `configs.sh` — symlinks dotfiles into your home directory
- `linux/` — Linux packages, system configs, desktop configs, and helpers
- `macos/` — macOS packages, app configs, and helpers
- `resources/wallpapers/` — wallpapers

## Setup

### Linux

```bash
./install.sh
./configs.sh
```

Uses `yay` and `sudo` for a few system-level symlinks/services.

### macOS

```bash
./install.sh
./configs.sh
```

Uses Homebrew. Set `WORKPLACE=1` before `./install.sh` to install workplace-only extras.

## Notes

- `install.sh` clones `base16-shell` and `kickstart-modular.nvim`.
- `configs.sh` also links `.pi/`.
- Linux key remaps are handled by `keyd`; macOS uses Karabiner.
- Some parts are still opinionated/WIP, so review before running on a fresh machine.
