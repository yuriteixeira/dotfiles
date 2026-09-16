# Objectives & Principles

## 0. Interoperable, Multi-modal & FOSS-Centric

Use the same apps on both Linux (personal), MacOS (work) & iOS devices (iPad is personal, phone is work) as much as possible and prioritize FOSS software.

## 1. Keyboard centric

- Tiling window manager
  - Graphical
    - MacOS: Aerospace
    - Linux: Sway (for now, Hyprland was too unstable)
  - Terminal
    - Tmux (the terminal's "tiling window manager")

- Allow hands to be on keyboard's "home row" as much as possible (for health & ergonomics)
  - Vim mode as much as possible (through settings or plugins/extensions, eg: vimium on Brave, vi mode on zsh and Obsidian, etc)
  - Caps lock = Esc
  - Caps lock + hjkl = Arrow keys

**NOTE**: Re: remappings, I'm using `keyd` now, which allows for remappings even outside the WM, BUT it doesn't play well with macbook trackpads sometimes, meaning that "palm rejection" isn't working well and needs to be fixed (#todo). Also, a bonus feature (even though I'm living ok without it) is the "HyperKey" mapping I have on Mac (Caps lock HELD = Meta + Alt + Shift + Ctrl) also working on Linux (#todo, but this worked in my tests with Omarchy on a separate macbook)

## 2. Easily Reproducible (and don't even mention NixOS!)

**NOTES**:

1. Re: linux, I'm set for ArchLinux on the laptops & VoidLinux on the server. Both are rolling distros (which I love), but the latter is more stable. 

I almost went "full Void" (even on the laptops), but in order to make the `./configs.sh` (and the future `./install.sh`) simpler, I went "Full Arch".

## 3. Consistenly working across the board

- Concise & consistent UI/UX (things should look good altogether, dark/light mode should be respected by all apps, my fave wallpapers and fonts, etc)
- Mixer
- Blu-ray player
- Printer
- Web-cam
- Keyboard
- Bluetooth audio (headset)
- Bluetooth keyboard
- Monitors and their modes (laptop + top, clamshell + 1/2)

# A few highlights on my choices:

## Terminal emulator: Alacritty (Linux & MacOS)

The most bare-bones one & GPU accelerated choice I know, which lacks modern features like splits/tabs (a tmux responsibility) and image rendering.

## Browser: Brave (Linux, MacOS and iOS)

Chromium based + Privacy + a nice Sync feature.

## Note taker: Obsidian (Linux, MacOS and iOS)

Save files as plain markdown (allowing it to be easily edited on any editor) and since I have my vault on a repo, all plugins and configs come bundled on every installation I make.

## Office Suite: LibreOffice (Linux & MacOS*) + Collabora (iOS)

Since I migrated away from Google Drive and converted all my docs into Microsoft's open standard (to guarantee maximum compatibility), I just moved my files to a Samba share on my server and therefore, an Office Suite is needed to open them.

On iOS, the closest I got to LibreOffice was Collabora (which is based on it). The UX is terrible, but unfortunately OnlyOffice doesn't play well with samba shares.

## Local send (GUI) / Croc (CLI) for copy/paste between devices

Not as smooth as the seamless network copy/paste on Apple's ecosystem, but it's good enough.

## Core utils

CLI + TUI centric. A few classics were replaced by more modern tools. 

See `cliTools` in  `./install.sh` for more details.
