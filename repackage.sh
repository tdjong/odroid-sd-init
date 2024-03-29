#!/bin/bash
# unmount image
# recompress image to xz

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/settings.ini"

if [ -z "${GitHubUser}" ]; then
  echo "Check settings.ini. GitHubUser is empty."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Filename of RAW image is required"
  exit 1
fi
if [ ! -f "$1" ]; then
  echo "File: $1 not found."
  exit 1
fi

sudo umount "$1"
file "$1"
ls -l "$1"

xz -v --keep < "$1" > "${GitHubUser}_$1.xz"

ls -l "${GitHubUser}_$1.xz"

echo "Image ready to flash to microsd"
echo "After installation ansible should be able to finish the configuration"
