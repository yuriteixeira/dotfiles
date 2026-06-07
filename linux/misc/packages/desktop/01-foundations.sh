# Fonts
yay -S --noconfirm --needed \
  noto-fonts-emoji \

# Font management 
yay -S --noconfirm --needed \
  font-manager \

# Audio
yay -S --noconfirm --needed \
  pipewire \
  pipewire-alsa \
  pipewire-jack \
  pipewire-pulse \
  wiremix \
  wireplumber \

# Bluetooth
# NOTE: bluetui might bring bluez, but leaving as an explicit entry 
# since I might change the UI for managing BT devices later.
yay -S --noconfirm --needed \
  bluetui \
  bluez \

# Keyboard special keys
yay -S --noconfirm --needed \
  brightnessctl \
  playerctl \

# Network discovery (needed for reaching hostnames with .local)
yay -S --noconfirm --needed \
  avahi \
  nss-mdns \

# Transfer clipboard/files to another computer 
# GUI: localsend
# TUI: croc
yay -S --noconfirm --needed \
  croc \
  localsend-bin \

# Wi-fi picker
yay -S --noconfirm --needed \
  impala \

# VPN
yay -S --noconfirm --needed \
  nordvpn-bin \

# Polkit & XDG Portals
yay -S --needed --noconfirm \
  polkit-gnome \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-wlr \

# Top bar
yay -S --noconfirm --needed \
  waybar \

# Monitor configuration generator
yay -S --noconfirm --needed \
  nwg-displays \
 
# Notifications
yay -S --noconfirm --needed \
  mako \

# Screenshot tools
yay -S --noconfirm --needed \
  sway-contrib \

# Clipboard
# See also: wtype, cliphist (grep repo for previous setup using it)
yay -S --noconfirm --needed \
  wl-clipboard \
  cliphist \

# Launcher + opt. dep to enable the calculator 
# See also: wofi (grep repo for previous setup using it)
yay -S --noconfirm --needed \
  rofi \
  rofi-emoji \
  rofi-calc \
