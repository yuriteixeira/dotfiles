#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
PATCH_FILE="$ROOT/stable/patches/0005-macbook12-spi-driver-linux-7-compat.patch"
SRC=/usr/src/macbook12-spi-driver-0+git.315
STAMP=$(date +%Y%m%d-%H%M%S)

[[ -d "$SRC" ]] || {
  echo "$SRC is missing; install macbook12-spi-driver-dkms 0+git.315 first." >&2
  exit 1
}

installed=$(pacman -Q macbook12-spi-driver-dkms 2>/dev/null | awk '{print $2}')
[[ "$installed" == "0+git.315-1" ]] || {
  echo "Expected package version 0+git.315-1; found ${installed:-none}." >&2
  exit 1
}

if sudo patch --batch --dry-run --silent -d / -p1 < "$PATCH_FILE"; then
  for file in applespi.c apple-ibridge.c apple-ib-tb.c apple-ib-als.c; do
    sudo cp -a -- "$SRC/$file" "$SRC/$file.bak.$STAMP"
  done
  sudo patch --batch -d / -p1 < "$PATCH_FILE"
elif sudo patch --batch --dry-run --silent --reverse -d / -p1 < "$PATCH_FILE"; then
  echo "Compatibility patch is already applied."
else
  echo "Source does not match either side of the version-specific patch." >&2
  exit 1
fi

sudo dkms install -m macbook12-spi-driver -v 0+git.315 --force
sudo depmod -a
echo "Patched source and rebuilt macbook12-spi-driver DKMS modules."
