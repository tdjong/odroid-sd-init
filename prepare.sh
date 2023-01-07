#!/bin/bash
# Prepare Raw image for unattended boot
# Requires:
# * full linux distrution - not WSL1
# * downloaded authorized keys for non-root account
# * downloaded Linux distribution RAW images (typically *.img* or *.raw*)
# Tasks:
# * decompress raw image
# * mount boot
# * prepare boot
# * mount root
# * prepare root
# * recompress boot & root

los() (
  img="$1"
  dev="$(sudo losetup --show -f -P "$img")"
  echo "$dev"
  for part in "$dev"?*; do
    if [ "$part" = "${dev}p*" ]; then
      part="${dev}"
    fi
    dst="$HOME/mnt/$(basename "$part")"
    echo "$dst"
    sudo mkdir -p "$dst"
    sudo mount "$part" "$dst"
  done
)
losd() (
  dev="/dev/$1"
  for part in "$dev"?*; do
    if [ "$part" = "${dev}p*" ]; then
      part="${dev}"
    fi
    dst="$HOME/mnt/$(basename "$part")"
    sudo umount "$dst"
  done
  sudo losetup -d "$dev"
)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/settings.ini"

if [ -z "$1" ]; then
  echo "Filename of RAW image is required"
  ls -l "*.img*"
  exit 1
fi
if [ ! -f "$1" ]; then
  echo "File: $1 not found."
  exit 1
fi
file "$1"

RAWFILE=$(basename "$1" .xz)
# assume xz compression for now
if [ "$1" != "$RAWFILE" ]; then
    echo "Decompress, assuming xz format"
    xz -v --keep --decompress "$1"
fi

if [ ! -f "$RAWFILE" ]; then
  echo "Decompress failed. Exitting"
  exit 2
fi

set -x
set -e 

file "$RAWFILE"
loopdev=$(los "$RAWFILE")
loopdev=$(echo "$loopdev" | head -n 1)
loopdev=${loopdev#/dev/}
echo "loopdev = $loopdev"
ls -l "$HOME/mnt"

#./mount-raw-boot.sh "$RAWFILE"
#./mount-raw-root.sh "$RAWFILE"
for i in "boot" "root";
do 
  if [ -d ~/mnt/$i ]; then
    rm ~/mnt/$i
  fi
done
ln -s "$HOME/mnt/${loopdev}p1" "$HOME/mnt/boot"
ln -s "$HOME/mnt/${loopdev}p2" "$HOME/mnt/root"

./tweak-boot.sh
./tweak-root.sh

losd "$loopdev"

./repackage.sh "$RAWFILE"
