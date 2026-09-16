# Dotfiles

My Linux/macOS dotfiles and setup scripts.

## Objectives & Principles

See [OBJECTIVES_AND_PRINCIPLES.md](./docs/OBJECTIVES_AND_PRINCIPLES.md).

## What's in?

- `install.sh` — top-level installer; dispatches to `linux/` (Arch Linux assumed) or `macos/`
- `configs.sh` — symlinks dotfiles into your home directory
- `linux/` — Linux packages, system configs, desktop configs, and helpers
- `macos/` — macOS packages, app configs, and helpers
- `resources/wallpapers/` — wallpapers

## Setup


```bash
./install.sh
./configs.sh
```

Set `WORKPLACE=1` before `./install.sh` to install workplace-only extras.

### Optional (linux): hibernation setup on Btrfs systems:

```bash
sudo ./linux/misc/setup-hibernation-swapfile.sh 40g
```

This creates `/swap/swapfile`, configures `resume` for mkinitcpio/systemd-boot, and should be followed by a reboot.
