#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
PATCH_DIR="$ROOT/stable/patches"
STAMP=$(date +%Y%m%d-%H%M%S)

command -v patch >/dev/null || {
  echo "The 'patch' command is required." >&2
  exit 1
}
command -v pacman >/dev/null || {
  echo "This helper targets Arch Linux/Omarchy (pacman not found)." >&2
  exit 1
}

sudo pacman -S --needed keyd terminus-font linux-headers base-devel wget

backup_if_present() {
  local path=$1
  if [[ -e "$path" ]]; then
    sudo cp -a -- "$path" "$path.bak.$STAMP"
  fi
}

apply_root_patch() {
  local file=$1
  if sudo patch --batch --dry-run --silent -d / -p1 < "$file"; then
    sudo patch --batch -d / -p1 < "$file"
  elif sudo patch --batch --dry-run --silent --reverse -d / -p1 < "$file"; then
    echo "Already applied: ${file##*/}"
  else
    echo "Cannot cleanly apply ${file##*/}; no changes made for this patch." >&2
    exit 1
  fi
}

apply_home_patch() {
  local file=$1
  if patch --batch --dry-run --silent -d "$HOME" -p1 < "$file"; then
    patch --batch -d "$HOME" -p1 < "$file"
  elif patch --batch --dry-run --silent --reverse -d "$HOME" -p1 < "$file"; then
    echo "Already applied: ${file##*/}"
  else
    echo "Cannot cleanly apply ${file##*/}; no changes made for this patch." >&2
    exit 1
  fi
}

backup_if_present /etc/keyd/default.conf
backup_if_present /etc/udev/rules.d/99-apple-spi-touchpad.rules
backup_if_present /etc/vconsole.conf
[[ ! -e "$HOME/.config/hypr/input.lua" ]] || cp -a -- "$HOME/.config/hypr/input.lua" "$HOME/.config/hypr/input.lua.bak.$STAMP"

apply_root_patch "$PATCH_DIR/0001-keyd-default-config.patch"
apply_root_patch "$PATCH_DIR/0002-apple-spi-touchpad-udev.patch"
apply_root_patch "$PATCH_DIR/0003-terminus-vconsole.patch"
apply_home_patch "$PATCH_DIR/0004-hypr-touchpad-disable-while-typing.patch"

sudo systemctl enable --now keyd.service
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=input --action=change
sudo systemctl restart systemd-vconsole-setup.service

if command -v limine-mkinitcpio >/dev/null; then
  sudo limine-mkinitcpio
elif command -v mkinitcpio >/dev/null; then
  sudo mkinitcpio -P
fi

if command -v hyprctl >/dev/null && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  hyprctl reload
  hyprctl configerrors
fi

echo "Stable patches applied. Backups use suffix .bak.$STAMP"
