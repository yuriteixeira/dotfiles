#!/usr/bin/env bash
set -euo pipefail

SWAP_SIZE="${1:-40g}"
SWAP_DIR="/swap"
SWAP_FILE="$SWAP_DIR/swapfile"
STAMP="$(date +%Y%m%d-%H%M%S)"

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "ERROR: run as root, e.g.: sudo $0 ${SWAP_SIZE}" >&2
    exit 1
  fi
}

strip_subvolume_suffix() {
  # findmnt can return /dev/mapper/root[/@] for a Btrfs subvolume mount.
  printf '%s\n' "${1%%\[*}"
}

ensure_btrfs_root() {
  local root_fstype
  root_fstype="$(findmnt -no FSTYPE /)"

  if [[ "$root_fstype" != "btrfs" ]]; then
    echo "ERROR: this script expects / to be Btrfs, got: $root_fstype" >&2
    exit 1
  fi
}

ensure_swapfile() {
  echo "==> Creating Btrfs swap subvolume/file"

  if [[ ! -e "$SWAP_DIR" ]]; then
    btrfs subvolume create "$SWAP_DIR"
  elif ! btrfs subvolume show "$SWAP_DIR" >/dev/null 2>&1; then
    if [[ -d "$SWAP_DIR" && -z "$(find "$SWAP_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
      rmdir "$SWAP_DIR"
      btrfs subvolume create "$SWAP_DIR"
    else
      echo "ERROR: $SWAP_DIR exists and is not an empty directory or Btrfs subvolume" >&2
      exit 1
    fi
  fi

  chmod 700 "$SWAP_DIR"

  if [[ ! -e "$SWAP_FILE" ]]; then
    btrfs filesystem mkswapfile --size "$SWAP_SIZE" --uuid clear "$SWAP_FILE"
  else
    echo "==> $SWAP_FILE already exists; leaving it in place"
  fi

  chmod 600 "$SWAP_FILE"

  if ! swapon --show=NAME --noheadings | grep -Fxq "$SWAP_FILE"; then
    swapon --priority 10 "$SWAP_FILE"
  fi
}

ensure_fstab() {
  echo "==> Updating /etc/fstab"
  cp -a /etc/fstab "/etc/fstab.bak-$STAMP"

  if ! grep -Eq '^[^#]+[[:space:]]+/swap/swapfile[[:space:]]+' /etc/fstab \
    && ! grep -Eq '^[^#]+[[:space:]]+none[[:space:]]+swap[[:space:]].*/swap/swapfile' /etc/fstab; then
    cat >> /etc/fstab <<'EOF'

# Persistent swapfile used for hibernation; zram remains preferred for runtime swap.
/swap/swapfile none swap defaults,pri=10 0 0
EOF
  fi
}

ensure_mkinitcpio_resume_hook() {
  echo "==> Updating /etc/mkinitcpio.conf"
  cp -a /etc/mkinitcpio.conf "/etc/mkinitcpio.conf.bak-$STAMP"

  python - <<'PY'
from pathlib import Path
import re

path = Path('/etc/mkinitcpio.conf')
text = path.read_text()
match = re.search(r'^HOOKS=\(([^)]*)\)', text, flags=re.M)
if not match:
    raise SystemExit('ERROR: Could not find HOOKS=(...) in /etc/mkinitcpio.conf')

hooks = match.group(1).split()
if 'resume' not in hooks:
    if 'encrypt' in hooks:
        hooks.insert(hooks.index('encrypt') + 1, 'resume')
    elif 'block' in hooks:
        hooks.insert(hooks.index('block') + 1, 'resume')
    else:
        hooks.append('resume')

    text = text[:match.start()] + 'HOOKS=(' + ' '.join(hooks) + ')' + text[match.end():]
    path.write_text(text)
PY
}

update_systemd_boot_entries() {
  local resume_device="$1"
  local resume_offset="$2"
  local updated_any=false

  echo "==> Updating systemd-boot loader entries"

  for entry in /boot/loader/entries/*.conf; do
    [[ -f "$entry" ]] || continue

    if grep -q '^options ' "$entry"; then
      cp -a "$entry" "$entry.bak-$STAMP"
      ENTRY="$entry" RESUME_DEVICE="$resume_device" RESUME_OFFSET="$resume_offset" python - <<'PY'
from pathlib import Path
import os

path = Path(os.environ['ENTRY'])
resume_device = os.environ['RESUME_DEVICE']
resume_offset = os.environ['RESUME_OFFSET']

lines = path.read_text().splitlines()
new_lines = []
for line in lines:
    if line.startswith('options '):
        parts = [
            part for part in line.split()
            if not part.startswith('resume=') and not part.startswith('resume_offset=')
        ]
        parts.extend([f'resume={resume_device}', f'resume_offset={resume_offset}'])
        line = ' '.join(parts)
    new_lines.append(line)

path.write_text('\n'.join(new_lines) + '\n')
PY
      echo "updated $entry"
      updated_any=true
    fi
  done

  if [[ "$updated_any" != true ]]; then
    echo "ERROR: no systemd-boot loader entries found under /boot/loader/entries" >&2
    exit 1
  fi
}

main() {
  require_root
  ensure_btrfs_root

  local resume_device resume_offset
  resume_device="$(strip_subvolume_suffix "$(findmnt -no SOURCE /)")"

  ensure_swapfile
  resume_offset="$(btrfs inspect-internal map-swapfile -r "$SWAP_FILE")"
  echo "==> Resume device: $resume_device"
  echo "==> Resume offset: $resume_offset"

  ensure_fstab
  ensure_mkinitcpio_resume_hook

  echo "==> Regenerating initramfs"
  mkinitcpio -P

  update_systemd_boot_entries "$resume_device" "$resume_offset"

  cat <<EOF

==> Done. Reboot before testing hibernation.

Current swap devices:
$(swapon --show)

Current mkinitcpio hooks:
$(grep '^HOOKS=' /etc/mkinitcpio.conf)

Current boot options:
$(grep -H '^options ' /boot/loader/entries/*.conf)
EOF
}

main "$@"
