# Experimental T1 recovery source patches

**These patches are unreviewed and the attempted workflow failed before creating
valid FDR data. Do not proceed to phase B, memory boot, or ESP installation.**

Prefer recovery through macOS on an external disk. Read
`../../notes/touchbar-findings.md` first. Never call `SOCW(1)` on a T1 Mac.

## Included diffs

- `libirecovery-x619.patch` — adds the `iBridge1,1` / `x619ap` identity.
- `usbmuxd-any-device-class.patch` — accepts restored interfaces regardless of
  USB device class.
- `idevicerestore-t1-fdr.patch` — guarded T1 identity, EmbeddedOS, FDR, and
  preflight modifications.
- `helpers.patch` — creates `build-stack.sh` and `pbzx_extract.py`.

## Recreate source worktrees only

The following command clones exact historical commits and applies the patches.
It does **not** download Apple firmware, build, run a restore, access USB,
write the ESP, or create private device data.

```bash
./experimental/t1-recovery/prepare-sources.sh ~/t1-linux-work-recreated
```

The generated `build-stack.sh` records the original build order, but dependency
installation and building are intentionally not automated here.

## Privacy exclusions

The bundle excludes all content under `/var/lib/t1-touchbar/private`, including
recovery queries, identifiers, logs, FDR attempts, tickets, and blobs. It also
excludes the downloaded `EmbeddedOSFirmware.pkg`, extracted firmware, build
outputs, installed prefix, and binaries.
