# Based on https://github.com/basecamp/omarchy/blob/94006b5bb1e5c8ba105bc28ee3dce7a6e9e30b18/install/config/hardware/printer.sh

yay -S --noconfirm --needed \
  cups \
  cups-filters \
  cups-pdf \
  system-config-printer

# Needed for my Canon TS3400 
# See: https://forum.manjaro.org/t/install-canon-pixma-ts3450-printer/89495/2
yay -S --noconfirm --needed \
  cnijfilter2 \

sudo systemctl enable --now cups.service

# Disable multicast dns in resolved. Avahi will provide this for better network printer discovery
sudo mkdir -p /etc/systemd/resolved.conf.d

echo -e "[Resolve]\nMulticastDNS=no" | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf

sudo systemctl enable --now avahi-daemon.service
