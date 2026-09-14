#!/usr/bin/env bash
set -euo pipefail

BUNDLE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
WORK=${1:-"$HOME/t1-linux-work-recreated"}
mkdir -p "$WORK"

clone_at() {
  local name=$1 url=$2 commit=$3
  if [[ ! -d "$WORK/$name/.git" ]]; then
    git clone "$url" "$WORK/$name"
  fi
  git -C "$WORK/$name" fetch origin
  git -C "$WORK/$name" checkout --detach "$commit"
}

clone_at libplist https://github.com/libimobiledevice/libplist.git 32428abacb909988e8e960a8845a6430b17b6a60
clone_at libimobiledevice-glue https://github.com/libimobiledevice/libimobiledevice-glue.git da770a7687f35fbb981db4d7b47b1b032cd5c2c7
clone_at libtatsu https://github.com/libimobiledevice/libtatsu.git 60a39f36d719344360ec2e87563ed43f61f0530f
clone_at libirecovery https://github.com/libimobiledevice/libirecovery.git 95dec3aa25b1e30654ca107eb971971f6a216520
clone_at libusbmuxd https://github.com/libimobiledevice/libusbmuxd.git 93eb168bf6b07472d17781328c21df0c60300524
clone_at libimobiledevice https://github.com/libimobiledevice/libimobiledevice.git fa0f79190142bc309307967c058f89c1b36eb6b8
clone_at usbmuxd https://github.com/libimobiledevice/usbmuxd.git 3ded00c9985a5108cfc7591a309f9a23d57a8cba
clone_at idevicerestore https://github.com/libimobiledevice/idevicerestore.git 540c352c4c44896f7415abef87a166e8bbaea9b0

apply_repo_patch() {
  local repo=$1 patch_file=$2
  if git -C "$WORK/$repo" apply --check "$patch_file"; then
    git -C "$WORK/$repo" apply "$patch_file"
  elif git -C "$WORK/$repo" apply --reverse --check "$patch_file"; then
    echo "Already applied: ${patch_file##*/}"
  else
    echo "Cannot apply ${patch_file##*/} to $repo" >&2
    exit 1
  fi
}

apply_repo_patch libirecovery "$BUNDLE/patches/libirecovery-x619.patch"
apply_repo_patch usbmuxd "$BUNDLE/patches/usbmuxd-any-device-class.patch"
apply_repo_patch idevicerestore "$BUNDLE/patches/idevicerestore-t1-fdr.patch"

if patch --batch --dry-run --silent -d "$WORK" -p1 < "$BUNDLE/patches/helpers.patch"; then
  patch --batch -d "$WORK" -p1 < "$BUNDLE/patches/helpers.patch"
elif patch --batch --dry-run --silent --reverse -d "$WORK" -p1 < "$BUNDLE/patches/helpers.patch"; then
  echo "Helper files already present."
else
  echo "Cannot create helper files; targets differ." >&2
  exit 1
fi
chmod +x "$WORK/build-stack.sh" "$WORK/pbzx_extract.py"

echo "Prepared source trees under $WORK. No firmware or restore operation was run."
