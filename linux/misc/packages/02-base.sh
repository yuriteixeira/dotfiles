# BTRFS
yay -S --noconfirm --needed \
  btrfsmaintenance \

# Backup: Snapshots
# See also: pacback (grep repo for previous setup using it)
yay -S --noconfirm --needed \
  snapper \
  snapper-rollback \
  snap-pac \

# SSH (Remote access & keys, useful to install Arch from another computer with better editing and internet browsing capabilities)
yay -S --noconfirm --needed \
  openssh \

# Unzip 
yay -S --noconfirm --needed \
  unzip \
  7zip \

# Finger-print support (see config details in https://wiki.archlinux.org/title/Fprint#Configuration & https://github.com/uunicorn/python-validity?tab=readme-ov-file#enabling-fingerprint-for-system-authentication)
[ "$FINGERPRINT" = "1" ] && \
  yay -S --noconfirm --needed \
    python-validity \

# TTY font
yay -S --noconfirm --needed \
  terminus-font \

# Networking
yay -S --noconfirm --needed \
  tailscale \
  smbclient \

# Man pages
yay -S --noconfirm --needed \
  man-db \
  man-pages \

# Secondary package manager (if yay couldn't provide accordingly)
yay -S --noconfirm --needed \
  flatpak \

# Video card management (eg: glxinfo)
yay -S --noconfirm --needed \
  mesa-utils \

# E-mail client (but I just use it to use .mbox files that I downloaded from Google Takeout)
yay -S --noconfirm --needed \
  neomutt \

# Keyboard re-mapping
yay -S --noconfirm --needed \
  keyd \
