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
# 
# * mount root
# * prepare root
# * 

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
# assume xz compression for now
if [ "$1" != "$RAWFILE" ]; then
    echo "Decompress, assuming xz format"
    xz -v --decompress "$1"
fi

if [ ! -f "$RAWFILE" ]; then
  echo "Decompress failed. Exitting"
  exit 2
fi

./mount-raw-boot.sh $RAWFILE
./prepare-boot.sh

./mount-raw-root.sh $RAWFILE
./prepare-root.sh

./repackage.sh