# Project Context

## Project Overview

This repository contains a comprehensive set of dotfiles for both **Arch Linux** and **macOS**. It is designed with a **keyboard-centric** philosophy, prioritizing Vim-style navigation, tiling window managers, and terminal-based tools.

### Core Principles

1.  **Interoperable & Multi-modal:** Use the same tools (Alacritty, Brave, Obsidian, Tmux, Neovim) across Linux and macOS.
2.  **Keyboard-Centric:** Minimize mouse usage.
  - **Linux:** Sway (Wayland tiling window manager).
  - **macOS:** Aerospace (i3-like tiling window manager).
  - **Remapping:** `keyd` (Linux) and `Karabiner` (macOS) are used to map `Caps Lock` to `Esc` (tap) and `Arrow Keys` (hjkl when held).
3.  **Reproducible:** Automated installation and configuration scripts (WIP).

## Key Technologies

- **Shell:** `zsh` (currently using Oh-My-Zsh) with `base16` color schemes.
- **Terminal:** `Alacritty` (GPU-accelerated, bare-bones).
- **Multiplexer:** `tmux` for window management within the terminal.
- **Editor:** `Neovim` (configured with https://github.com/yuriteixeira/kickstart-modular.nvim).
- **Window Managers:** `Sway` (Linux), `Aerospace` (macOS).
- **System Utils:** `eza` (ls), `bat` (cat), `zoxide` (cd), `ripgrep` (grep), `fd` (find), `btop` (top), `fastfetch`.

## Project Structure

- `install.sh`: Main entry point for installing system dependencies (via `yay` on Linux and `Homebrew` on macOS).
- `configs.sh`: Symlinks configuration files from the repository to the user's home directory and `.config`.
- `linux/`: Linux-specific scripts and configurations (`sway`, `waybar`, `mako`, `rofi`, `keyd`, etc.).
- `macos/`: macOS-specific configurations (`aerospace`, `karabiner`, `alfred`, `borders`).
- `.zshrc_*`: Modularized zsh configuration files (e.g., `.zshrc_git`, `.zshrc_tmux`, `.zshrc_fzf`).
- `.tmux.*.conf`: Modularized tmux configuration files.
- `resources/wallpapers/`: Curated desktop backgrounds.

## Installation and Setup

### 1. Install Dependencies

Run the main installation script to install required packages and tools:

```bash
./install.sh
```
*Note: This script uses `yay` for Arch Linux and `brew` for macOS.*

### 2. Apply Configurations

Symlink the repository files to your system:
```bash
./configs.sh
```
*Note: On Linux, this script will prompt for `sudo` to symlink system-level configurations (e.g., in `/etc`).*

## Development Guidelines & Maintenance Conventions

- **Commits**: Use conventional commits (eg: "type-of-change(module): title") and add a concise markdown formatted description explaining the change and adding links for external references when applicable.
- **Clean Architecture**: Clean code (from Uncle Bob's book) and SOLID engineering principles should always be observed.
- **Modularity:** Shell and Tmux configurations are split into multiple files for better organization.
- **FOSS-First:** Prioritize Open Source software wherever possible.
- **Surgical Updates:** When modifying configurations, ensure they align with the fragmented structure (e.g., add git aliases to `.zshrc_git`).
- **Platform Awareness:** Always check for `uname` before applying platform-specific commands or symlinks.
