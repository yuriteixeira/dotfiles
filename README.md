# My setup

How to install? Choose your own adventure


## The "Regular Mac/ArchLinux" way

Run `./install.sh` and hope for the best (not done yet! #todo)


## The "Change is the only constant" way

1. (Linux only) Check ./linux/packages : here will be scripts to with my curation, separated by area/category (linux only, for now).

2. Check ./configs.sh and ./linux/configs.sh. There you will find a few good defaults (at least, for me :D).

3. **Copy/paste what you need into the terminal and enjoy :)**


# Objectives & Principles

## 0. Interoperable, Multi-modal & FOSS-Centric

Use same apps on both Linux (personal), MacOS (work) & iOS devices (iPad is personal, phone is work) as much as possible and prioritize FOSS sofware.

The FOSS part should be oubvious ;-) So far, those are my choices.


### Terminal emulator: Alacritty (Linux & MacOS)

The most bare-bones one & GPU accelerated choice I know, including lacking image rendering, which is supported by Kitty and Ghostty, but for now, I didn't find any use-case that requires it (maybe when I try a TUI-based file explorer).

Even splits or tabs (which one finds in most alternatives) isn't implemented, which is great since I use tmux for those things.


### Browser: Brave (Linux, MacOS and iOS)

Despite being chromium based, it is more privacy oriented, but the game changer for me is the sync feature, which allows me to cover some basis that Apple's Continuity/Hand-off did for me before (like sending a page I'm reading on a device to another). I find their news module interesting too in order to keep up with news through RSS, but it was a bit buggy last time I tried, however, I should try it again and see if it syncs the feeds I chose amongst all devices too.


### Note taker: Obsidian (Linux, MacOS and iOS)

For most of my writting needs (notes, recipes, journaling, research). Save files as plain markdown (allowing it to be easily edited on any editor) and since I have my vault on a repo, all plugins and configs come bundled on every installation I make.

**NOTE**: For work, I still use Apple Notes, since its sync mechanism is so seamless and reliable, but I should move my personal ones from it ASAP (#todo).


### Office Suite: LibreOffice (Linux & MacOS*) + OnlyOffice (iOS)

Since I migrated away from Google Drive and converted all my docs into the Microsoft's open standard (to guarantee maximum compability), I just moved my files to a Samba share on my server and therefore, an Office Suite is needed to open them. 

On iOS, the closest I got to LibreOffice was Collabora (which is based on it), but since the UX was terrible, I just went to OnlyOffice.


### Local send (GUI) / Croc (CLI) for copy/paste between devices

Not as smooth as the seamless network copy/paste on the Apple's eco-system, but its good enough.


### Core utils

- zsh + base16 themes (still with oh-my-zsh, but it seems I don't need it #todo)
- tmux (terminal on steroids)
- nvim + https://github.com/yuriteixeira/kickstart-modular.nvim
- ripgrep (text search tool, but I still use to filter output with grep #todo)
- git, gitui & delta (all things version-controll, with a nice ui + diff companion)
- @google/gemini-cli (agentic AI on terminal)
- bat (cat replacement)
- eza (ls/tree replacement)
- zoxide (cd/autojump replacement)
- fastfetch (system info)
- croc (network copy/paste, like localsend)
- dunst + ncdu (disk usage overview + explorer)
- rsync (for large transfers, both local or on network)
- rclone (swiss knife to transfer files + misc utils like webdav implementation)
- btop (process management TUI)



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

**NOTE**: Re: remappings, I'm using `keyd` now, which allows for remappings even outside the WM, BUT it doesn't play well with trackpas, meaning that "palm rejection" isn't working well and needs to be fixed (#todo). Also, a bonus feature (even though I'm living ok without it) is the "HyperKey" mapping I have on Mac (Caps lock HELD = Meta + Alt + Shift + Ctrl) also working on Linux (#todo).


## 2. Easily Reproducible (and don't even mention NixOS!)

That's an area of improvement: even though all the solutions can be found here, it should work by just running `./install.sh` (#todo).

**NOTES**: 

1. Re: linux, I'm set for ArchLinux on the laptops & VoidLinux on the server. Both are rolling distros (which I love), but the latter is more stable. I was almost going "full void" (even on the laptops), but in order to make the `./configs.sh` (and the future `./install.sh`) simpler, I think I should just go with Arch, thus the remaining laptop with Void (which is the X201, which I'm using to write this right now XD) should be migrated back to ArchLinux soon. 


## 3. Consistenly working across the board

- Concise & Consistent UI/UX (thinks should look good altogether, dark/light mode should be respected by all apps, my fave wallpapers and fonts, etc)
- Mixer
- Blu-ray player
- Printer 
- Web-cam
- Keyboard
- Bluetooth audio (headset)
- Bluetooth keyboard
- Monitors and their modes (laptop + top, clamshell + 1/2)
