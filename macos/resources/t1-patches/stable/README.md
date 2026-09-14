# Stable persistent changes

## Patch order

1. `0001-keyd-default-config.patch`
   - ISO/LSGT key → Escape
   - Caps tap → Escape; hold → Hyper (Ctrl+Super+Alt+Shift)
   - Fn+1–9 → F1–F9, including explicit Alt combinations
   - Hyper+H/J/K/L → arrow keys
2. `0002-apple-spi-touchpad-udev.patch`
   - Tags `Apple SPI Touchpad` as an internal touchpad.
3. `0003-terminus-vconsole.patch`
   - Changes console font from `default8x16` to `ter-v32n`.
4. `0004-hypr-touchpad-disable-while-typing.patch`
   - Enables Hyprland touchpad suppression while typing.
5. `0005-macbook12-spi-driver-linux-7-compat.patch`
   - Kernel-API compatibility edits made to version `0+git.315` under `/usr/src`.

## Main apply helper

```bash
./stable/apply-stable.sh
```

The helper applies patches 0001–0004 only. It creates timestamped backups and
refuses a hunk that is neither cleanly applicable nor already applied.

## Optional DKMS source patch

Only use patch 0005 when all of these are true:

- `macbook12-spi-driver-dkms` version `0+git.315` is installed;
- `/usr/src/macbook12-spi-driver-0+git.315` exists;
- you reviewed the driver and understand this patch is tied to that source;
- you need these Linux 7.x build fixes.

Apply and rebuild with:

```bash
./stable/apply-macbook12-spi-compat.sh
```

The historical Touch Bar investigation later identified unsafe T1 power logic
in this older driver. Do not use it to drive a restored T1 Touch Bar. See
`../notes/touchbar-findings.md`; keyboard/touchpad support and Touch Bar support
must be evaluated separately.

## Package delta observed in Pi sessions

Newly installed by the audited sessions:

- `linux-headers` (with `pahole` dependency)
- `wget`
- `keyd`
- `terminus-font`
- `acpi_call-dkms` (experimental T1 reset work)

Already present when requested: `base-devel`, `patch`, and `dkms`.
Package versions are intentionally not pinned because Arch kernel/header
versions must stay synchronized.
