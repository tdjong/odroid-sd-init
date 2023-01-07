#!/bin/bash
# Prepare Raw image for unattended boot
# Requires:
# * full linux distrution - not WSL1
# * downloaded authorized keys for non-root account
# * downloaded Linux distribution RAW images (typically *.img* or *.raw*)
# Tasks:
# * decompress raw
# * mount raw partition

if [ -z "$1" ]; then
  echo "Filename of RAW image is required"
  exit 1
fi
if [ ! -f "$1" ]; then
  echo "File: $1 not found."
  exit 1
fi
file "$1"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/settings.ini"

RAWFILE=$(basename "$1" .xz)
fdisk -l "$RAWFILE"

MNTDIR=${MNTDIR}/root
echo
echo "Select the root filesystem (probably the biggest ext4 linux partition)"
read -rp "Fdisk output - partition start: " partstart
read -rp "Fdisk output - Sector size: " sectorsize
echo "PartStart = $partstart and SectorSize = $sectorsize"
((offset=partstart*sectorsize))
echo Offset = "$offset"
if [ ! -d "$MNTDIR" ]; then
  mkdir -p "$MNTDIR"
fi
sudo mount -o loop,offset="$offset" "$RAWFILE" "$MNTDIR"
ls -l "$MNTDIR"
