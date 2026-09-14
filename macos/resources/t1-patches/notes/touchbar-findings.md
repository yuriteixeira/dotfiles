# MacBook Pro Touch Bar Investigation

## System

- Model: **MacBookPro13,3** (2016, Apple T1/iBridge)
- OS: Omarchy/Arch Linux
- Kernel during investigation: `7.1.9-arch1-2`

## Current diagnosis

The Touch Bar controller enumerates as:

```text
05ac:1281 Apple Mobile Device (Recovery Mode)
```

A working T1/iBridge should normally enumerate as:

```text
05ac:8600 iBridge
```

The Linux keyboard and touchpad work through the mainline `applespi` driver. Touch Bar-related kernel modules cannot create a Touch Bar input/display device while the T1 remains in recovery mode.

## Root cause

The current EFI System Partition does not contain the T1 EmbeddedOS files:

```text
EFI/APPLE/EMBEDDEDOS/combined.memboot
EFI/APPLE/EMBEDDEDOS/FDRData
EFI/APPLE/EMBEDDEDOS/version.plist
```

No copies of `combined.memboot` or `FDRData` were found in the user's home directory.

The T1 has no complete production firmware available in ROM. Apple's boot process loads its personalized EmbeddedOS image from the EFI System Partition during startup. Erasing Apple's original ESP during a full-disk Linux installation leaves the controller in `05ac:1281` recovery mode, disabling the Touch Bar and other T1-managed hardware.

An SMC reset was attempted but did not change the USB state.

## Recovery options

### 1. Restore this machine's original EFI backup

If an old backup of this Mac's `EFI/APPLE` directory exists on another disk or backup service, restoring it to the current ESP and rebooting has been reported to restore `05ac:8600` operation.

Do **not** use another Mac's `FDRData`, AP ticket, SHSH data, or personalized `combined.memboot`. These artifacts are bound to the physical T1 and may contain device provisioning identity.

### 2. Linux-only T1 activation (experimental)

A community procedure has successfully activated a T1 entirely from Linux. It:

1. Downloads generic EmbeddedOS firmware from Apple.
2. Uses a patched mobile-device restore stack to provision machine-specific `FDRData`.
3. Requests personalized firmware and a matching AP ticket from Apple.
4. Performs a T1 EmbeddedOS restore and phase-14 memory boot.
5. Verifies that the controller remains at `05ac:8600`.
6. Installs the proven `combined.memboot`, `FDRData`, and `version.plist` on the ESP.

The published success was on a **MacBookPro13,2**, T1 hardware model `x619ap`. This MacBookPro13,3 reports the same documented T1 CPID/BDID combination used in that test, but the exact activation workflow has not been verified on this model.

Important limitation: the required T1-specific `idevicerestore` and `usbmuxd` patches are not available as a reviewed, ready-to-use upstream release. Stock binaries do not implement the required FDR capture/replay and phase-14 controls. Reimplementing the patches is an expert recovery project and carries firmware risk.

### 3. Temporary external macOS installation

The least invasive established recovery path is to install or boot a supported macOS installation on an **external drive**, allow Apple's `EmbeddedOSInstallService` to regenerate the personalized T1 firmware on the internal ESP, and retain Linux on the internal disk.

Merely booting Internet Recovery is not strongly documented as sufficient. The repair generally occurs during macOS installation or first boot with network access.

## Linux driver findings

Once the device is restored to `05ac:8600`, it needs a T1-specific Linux driver. A current kernel-7-compatible project is:

- <https://github.com/AJ-dev-i60/t1-touchbar>

Its safety guidance is important:

- Use `skip_acpi_power=1`.
- Never force `skip_acpi_power=0` on T1 models.
- Calling the ACPI method `ASOC.SOCW(1)` can hard-freeze 2016–2017 T1 MacBooks.
- A reboot may be required so the driver binds before generic HID or `usbmuxd` claims the device.

An older `macbook12-spi-driver-dkms` Touch Bar build was temporarily patched and installed during diagnosis. Web research later showed that its unconditional `SOCW(1)` path could be unsafe after firmware recovery. It was therefore removed, its persistent module configuration was deleted, and the original mainline `applespi` module was restored. Keyboard and touchpad support remain intact.

## Sources

- Linux-only T1 activation research:  
  <https://gist.github.com/tigercosmos/ecbfe1fc20b7303c1808d3ab74af1f5b>
- Confirmed recovery-mode/erased-ESP diagnosis and restoration from backup:  
  <https://github.com/Dunedan/mbp-2016-linux/issues/52>
- Kernel-7-compatible T1 Touch Bar driver:  
  <https://github.com/AJ-dev-i60/t1-touchbar>
- Omarchy T1 investigation and ESP preservation guidance:  
  <https://github.com/nohzafk/omarchy-macbookpro-t1>
- Technical background on T1 EmbeddedOS personalization:  
  <https://blog.eriknicolasgomez.com/2016/11/30/the-untouchables-pt-2-offline-touchbar-activation-with-a-purged-disk/>
- Apple Configurator revive/restore documentation (applies to T2 and Apple silicon, not T1):  
  <https://support.apple.com/en-us/108900>

## Linux-only recovery attempt

A private restore stack was built from the source revisions documented by the Linux-only activation research. Required changes included:

- Adding the `iBridge1,1` / `x619ap` recovery identity to `libirecovery`.
- Allowing Apple's EmbeddedOS bundle format, which lacks `SupportedProductTypes`, only after verifying exact `x619ap`, CPID `0x8002`, and BDID `0x12` hardware.
- Patching `usbmuxd` to accept any restored USB device class.
- Adding guarded T1 EmbeddedOS restore options and private FDR input/output handling.
- Keeping all unique identifiers, FDR material, tickets, and restore logs under root-only `/var/lib/t1-touchbar/private`.

The restore successfully personalized and uploaded iBEC, RestoreRamDisk, RestoreDeviceTree, RestoreSEP, and RestoreKernelCache. The T1 entered temporary `05ac:8600` restored mode and connected through the patched `usbmuxd`.

Pass A then failed inside Apple's restore ramdisk before `FDRMemoryCommit`. Apple's FDR server responded successfully, but the ramdisk could not create its FDR storage path because its system partition was unavailable/read-only. It consequently reported no FDR state to restore and aborted FDR recovery. A single authorized retry with an empty, non-donor in-memory FDR dictionary reached the same failure and produced no `FDRData`.

No ESP or Linux filesystem content was changed by either attempt. The T1 was returned using only the documented `FRST` ACPI method to its original `05ac:1281` recovery state, and the private `usbmuxd` service was stopped. Phase B, phase 14, and ESP installation were **not** attempted because the required successful Pass A/FDR output was absent.

## Session-resume state

This section contains the operational details needed to continue later.

### Current machine state

- T1 USB state: `05ac:1281 Apple Mobile Device (Recovery Mode)`.
- Private experimental `t1-usbmuxd.service`: stopped/inactive.
- No `EFI/APPLE/EMBEDDEDOS/combined.memboot` is installed.
- No valid `FDRData` was generated.
- Do **not** continue with Pass B, phase 14, or ESP installation without a successful Pass A.
- The old unsafe Touch Bar DKMS modules and their `/etc/modules-load.d`/`modprobe.d` configuration were removed.
- Mainline `applespi` remains responsible for the working keyboard and trackpad.
- `acpi_call-dkms` is installed. The tested safe T1 reset is `\\_SB.PCI0.XHC1.RHUB.ASOC.FRST`, which returned `0x0`.
- Never call `SOCW(1)`.

### Working files

- Main research notes: `$HOME/touchbar-findings.md`
- Experimental source/build tree: `$HOME/t1-linux-work`
- Private root-only artifacts and logs: `/var/lib/t1-touchbar/private`
- Downloaded Apple package: `$HOME/t1-linux-work/download/EmbeddedOSFirmware.pkg`
- Expected package SHA-256: `0c97ab746ec635b34b1bdea4e4722cd0173443e2ba6ede54cc6af3b5e220d230`
- Extracted firmware resources: `$HOME/t1-linux-work/firmware/usr/standalone/firmware/iBridge1_1Customer.bundle/Contents/Resources`
- Patched `idevicerestore`: `$HOME/t1-linux-work/idevicerestore/src/idevicerestore`
- Private userspace prefix: `$HOME/t1-linux-work/prefix`

The private directory contains unique device identifiers and restore/FDR logs. Keep it root-only and never publish raw contents.

### Source revisions used

```text
libplist               32428ab
libimobiledevice-glue  da770a7
libtatsu               60a39f3
libirecovery           95dec3a
libusbmuxd             93eb168
libimobiledevice       fa0f791
usbmuxd                3ded00c
idevicerestore         540c352
```

Local patches are present in the worktree. They add the x619 identity, T1 restore/FDR guards, preflight capture scaffolding, and the required `usbmuxd` any-device-class filter. These patches are experimental and not upstream-reviewed.

### Recommended continuation

1. Install a supported macOS version onto an external SSD from Internet Recovery.
2. Never erase, repartition, or select the internal Linux disk as the macOS installation target.
3. Boot the external macOS installation with internet access and apply available updates, allowing `EmbeddedOSInstallService` to provision the T1 firmware.
4. Return to Linux and check whether the T1 changed from `05ac:1281` to `05ac:8600`.
5. If `05ac:8600` is stable, install the current T1 driver from <https://github.com/AJ-dev-i60/t1-touchbar> with `skip_acpi_power=1` before enabling persistent module loading.

An external macOS installation may change only the default NVRAM boot entry. If necessary, hold Option at startup to choose Linux or restore the Linux boot order with `efibootmgr`.

## Bottom line

The hardware is visible, but the T1 is missing its personalized boot firmware. Linux Touch Bar drivers alone cannot fix `05ac:1281`. The documented Linux-only workflow cannot safely continue on this machine because Apple's restore ramdisk fails before generating device-specific `FDRData`. Restoring this machine's own ESP backup remains the simplest Linux-only solution; otherwise, an external macOS installation is the lowest-risk established route that preserves the internal Linux setup.
