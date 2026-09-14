# CS8409 out-of-tree audio driver session

The audio session made no source-code edits, so there is no diff patch.
It performed these persistent actions:

1. Installed `linux-headers`, `wget`, and dependency `pahole`.
2. Cloned `davidjo/snd_hda_macbookpro` commit
   `6c324f6c9262faa853fdd74d798c5686937a9d0f` into `/tmp`.
3. Ran `install.cirrus.driver.sh -i`, registering DKMS module
   `snd_hda_macbookpro/0.1` and replacing the in-tree CS8409 module for the
   then-running kernel `7.1.9-arch1-2`.

## Important current-state defect

The installer registered `/usr/src/snd_hda_macbookpro-0.1` as a symlink to the
temporary clone. After `/tmp` was cleared and the kernel moved to 7.2.3, DKMS
became broken:

```text
snd_hda_macbookpro/0.1: broken
Missing the module source directory or symbolic link pointing to it
```

Do not reproduce the temporary-directory installation. Review current upstream
kernel compatibility first. If deliberately reinstalling, clone the pinned
source (or a reviewed newer revision) into a persistent directory and run its
installer from there:

```bash
sudo pacman -S --needed linux-headers base-devel patch wget dkms pahole
git clone https://github.com/davidjo/snd_hda_macbookpro.git ~/src/snd_hda_macbookpro
git -C ~/src/snd_hda_macbookpro checkout 6c324f6c9262faa853fdd74d798c5686937a9d0f
cd ~/src/snd_hda_macbookpro
sudo bash ./install.cirrus.driver.sh -i
```

This recipe is archival, not part of `stable/apply-stable.sh`.
