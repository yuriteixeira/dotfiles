set -ex
originalDir=$PWD
cd "$(dirname "$0")"

# Prep
ln -sfn "$PWD/.local/bin" $HOME/.local
ln -sfn "$PWD/.local/share/applications" $HOME/.local/share
ln -sfn "$PWD/.local/share/icons" $HOME/.local/share

# Window managers
ln -sfn "$PWD/.config/sway" $HOME/.config

# Graphical toolkits
ln -sfn "$PWD/.config/gtk-2.0" $HOME/.config
ln -sfn "$PWD/.config/gtk-3.0" $HOME/.config
ln -sfn "$PWD/.config/gtk-4.0" $HOME/.config

# Desktop environment
ln -sfn "$PWD/.config/swaylock" $HOME/.config
ln -sfn "$PWD/.config/mako" $HOME/.config
ln -sfn "$PWD/.config/waybar" $HOME/.config
ln -sfn "$PWD/.config/rofi" $HOME/.config

# Terminal
ln -sfn "$PWD/.config/alacritty" $HOME/.config

# TTY & Locale
sudo ln -sfn "$PWD/etc/vconsole.conf" /etc

# Network discovery (needed for reaching hostnames with .local)
sudo ln -sfn "$PWD/etc/nsswitch.conf" /etc

# Keyboard nav improvements: 
# Caps lock -> Esc
# Caps lock + h/j/k/l -> Arrow keys
sudo ln -sfn "$PWD/etc/keyd/default.conf" /etc/keyd
# Fix palm rejection issue: https://github.com/rvaiya/keyd/issues/66#issuecomment-2906522829
sudo ln -sfn "$PWD/usr/share/libinput/99-system-keyd.quirks" /usr/share/libinput
sudo systemctl enable --now keyd

# To unlock a user manually: faillock --user yuriteixeira --reset
sudo ln -sfn "$PWD/etc/security/faillock.conf" /etc/security

# Low battery protection
sudo mkdir -p /usr/local/bin /etc/systemd/system
sudo ln -sfn "$PWD/usr/local/bin/low-battery-handler" /usr/local/bin/
sudo ln -sfn "$PWD/etc/systemd/system/low-battery@.service" /etc/systemd/system/
sudo ln -sfn "$PWD/etc/udev/rules.d/99-lowbat.rules" /etc/udev/rules.d/
sudo systemctl daemon-reload
sudo udevadm control --reload-rules

# Snapshots of /boot
sudo mkdir -p /etc/pacman.d/hooks
sudo cp "$PWD/etc/pacman.d/hooks/55-bootbackup_pre.hook" /etc/pacman.d/hooks
sudo cp "$PWD/etc/pacman.d/hooks/55-bootbackup_post.hook" /etc/pacman.d/hooks
sudo chown root: /etc/pacman.d/hooks/55-bootbackup_pre.hook
sudo chown root: /etc/pacman.d/hooks/55-bootbackup_post.hook
sudo chmod 750 /etc/pacman.d/hooks/55-bootbackup_pre.hook
sudo chmod 750 /etc/pacman.d/hooks/55-bootbackup_post.hook

# Load settings for gnome-based apps
dconf load /org/gnome/desktop/ < ./misc/dconf-org-gnome-desktop-interface

# Mime types
xdg-mime default imv.desktop $(grep "^image/" /usr/share/mime/types)

cd $originalDir
set +x
