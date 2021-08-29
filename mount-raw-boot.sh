#!/bin/bash
# Prepare Raw image for unattended boot
# Requires:
# * full linux distrution - not WSL1
# * downloaded authorized keys for non-root account
# * downloaded Linux distribution RAW images (typically *.img* or *.raw*)
# Tasks:
# * mount raw boot partition and prepare it

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "${SCRIPT_DIR}/settings.ini"

if [ -z "$1" ]; then
  echo "Filename of RAW image is required"
  exit 1
fi
if [ ! -f "$1" ]; then
  echo "File: $1 not found."
  exit 1
fi
file "$1"

RAWFILE=$(basename "$1" .xz)
fdisk -l "$RAWFILE"
MNTDIR=~/mnt-boot

echo
echo "Select the boot filesystem (probably the first FAT partition)"
read -p "Fdisk output - partition start: " partstart
read -p "Fdisk output - Sector size: " sectorsize
echo "PartStart = $partstart and SectorSize = $sectorsize"
((offset=partstart*sectorsize))
echo Offset = "$offset"
mkdir $MNTDIR
sudo mount -o loop,offset="$offset" "$RAWFILE" $MNTDIR
ls -l $MNTDIR
