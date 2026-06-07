### System fixes

# Cedilla for US International Keyboard layouts
sudo sed -i '/cedilla/s/:wa/:en/' /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache
sudo sed -i '/cedilla/s/:wa/:en/' /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache
sudo sed -i '/cedilla/s/:wa/:en/' /usr/lib/gtk-2.0/2.10.0/immodules.cache
sudo sed -i '/cedilla/s/:wa/:en/' /usr/lib/gtk-3.0/3.0.0/immodules.cache

sudo sed -i 's/ć/ç/g' /usr/share/X11/locale/en_US.UTF-8/Compose
sudo sed -i 's/Ć/Ç/g' /usr/share/X11/locale/en_US.UTF-8/Compose

if command -v alacritty >&2; then
  sudo ln -s $(which alacritty) /usr/bin/xdg-terminal-exec
fi
