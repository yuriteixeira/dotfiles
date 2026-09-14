# Audit of all Pi sessions

Audited source: 10 JSONL files under `~/.pi/agent/sessions/`, spanning
2026-09-02 through the current 2026-09-14 bundle-generation session.

## Persistent changes found

### Audio diagnosis

- Installed `linux-headers`, `wget`, and dependency `pahole`.
- Installed an out-of-tree `snd_hda_macbookpro/0.1` DKMS driver from commit
  `6c324f6c9262faa853fdd74d798c5686937a9d0f`.
- The source was incorrectly linked to `/tmp/snd_hda_macbookpro`; it is now
  missing, and current `dkms status` reports the module as broken after a kernel
  update. No audio configuration file was changed.
- Archived in `experimental/audio/README.md`; not applied automatically.

### Touch Bar / T1 investigation

- Temporarily patched and installed `macbook12-spi-driver` modules, created
  `/etc/modules-load.d/apple-touchbar.conf` and
  `/etc/modprobe.d/apple-touchbar.conf`, then removed those two configuration
  files and removed the temporary DKMS registration during the investigation.
- Four compatibility edits remain in the package-owned source directory
  `/usr/src/macbook12-spi-driver-0+git.315`. They are captured by stable patch
  0005. Current package integrity reports those four files as altered.
- Installed `acpi_call-dkms`; the module remains installed for the current
  kernel. The `FRST` call and USB authorization writes were runtime-only.
- Created `~/t1-linux-work`, downloaded/extracted Apple firmware, cloned and
  built a private mobile-device restore stack, and patched `libirecovery`,
  `usbmuxd`, and `idevicerestore`. Source diffs and helper scripts are under
  `experimental/t1-recovery/`.
- Created root-only `/var/lib/t1-touchbar/private` containing logs and
  device-specific recovery material. It is deliberately excluded.
- No valid FDR data was generated; no phase B/memory boot occurred; no ESP file
  was written. The temporary `t1-usbmuxd` transient service was stopped.
- Created `~/touchbar-findings.md`, copied to `notes/`.

### Palm rejection

- Added `/etc/udev/rules.d/99-apple-spi-touchpad.rules`.
- Added a Hyprland override to `~/.config/hypr/input.lua` setting
  `disable_while_typing = true`.
- Reloaded udev at runtime.

### Keyboard remapping

- Installed `keyd`, created `/etc/keyd/default.conf`, and enabled/started
  `keyd.service`.
- Final mappings: LSGT→Esc; Caps tap→Esc/hold→Hyper; Fn+1–9→F1–F9;
  Fn+Alt+1–9→Alt+F1–F9; Hyper+H/J/K/L→arrows.
- A temporary Hyprland LSGT mapping was added and later removed in the same
  session, so there is no net Pi change to `~/.config/hypr/bindings.lua`.
  The later `im0001gt.screens` block in that file was not made by any audited
  Pi session and is excluded.

### TTY font

- Installed `terminus-font`.
- Changed `/etc/vconsole.conf` from `FONT=default8x16` to `FONT=ter-v32n`.
- Rebuilt the boot image. Generated initramfs/UKI outputs are not bundled.

## Runtime-only or no-change sessions

- Keyboard backlight was set to 255 through sysfs; this is runtime state, not a
  persistent file change.
- Computer-vs-ThinkPad comparison made no system changes.
- Diagnostic commands, module loads/unloads, USB resets, speaker tests, service
  status checks, web searches, `/tmp` files, and logs are not patches.

## Package delta attributable to sessions

Newly installed: `linux-headers`, `pahole`, `wget`, `keyd`, `terminus-font`, and
`acpi_call-dkms`.

Already installed when requested: `base-devel`, `patch`, and `dkms`.
`macbook12-spi-driver-dkms` was present before the Touch Bar session; its source
was modified by that session.

## Excluded for portability, privacy, or size

- `/var/lib/t1-touchbar/private/**`
- Apple firmware package and extracted firmware
- compiled objects, binaries, build logs, and private prefix
- package-manager caches, journal entries, initramfs/UKI images
- timestamped backup files
- unrelated changes not represented in Pi tool calls
- Pi credentials and session JSONL files themselves
