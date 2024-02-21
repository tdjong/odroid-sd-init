#!/bin/bash
set -x
set -e
# Prepare mounted raw image for unattended boot
# Requires:
# * mounted debian based distribution on ~/mnt
# * downloaded authorized keys for non-root account
# Note:
# * not compatible with WSL 1/2, full linux required
# Tasks:
# * Configure SSHD server
# * Create local non-root user
# * Allow non-root user to sudo
# * Add SSH authorized keys for easy access (ansible?)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/settings.ini" 

if [ ! -d "$MNTDIR/boot" ]; then
  echo "No boot partition mounted on $MNTDIR."
  ls "$MNTDIR"
  exit 1
fi

cd "$MNTDIR/boot/"
ls -l

echo "Odroid Ubuntu has bootargs in boot.ini"

cat << 'EOF'
# for containers (podman/minikube/docker)
setenv containers "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"

# SATA-to-USB bridge workaround (what is the right id? check lsusb)
# Odroid HC1 value: 
setenv hid_quirks "usb-storage.quirks=0x0bc2:0x2322:u"

# Boot Args
setenv bootargs "console=tty1 console=ttySAC2,115200n8 root=UUID=e139ce78-9841-40fe-8823-96a304a09859 rootwait \
                ro fsck.repair=yes net.ifnames=0 ${videoconfig} ${hdmi_phy_control} ${hid_quirks} \
                smsc95xx.macaddr=${macaddr} ${external_watchdog} ${containers}"
EOF

read -rp "Manually update $MNTDIR/boot/boot.ini. Press ENTER when you have the necessary code in your clipboard"
EDITOR=${EDITOR:-vi}
sudo cp "$MNTDIR/boot/boot.ini" "$MNTDIR/boot/boot.ini.$(date +%F)"
sudo $EDITOR "$MNTDIR/boot/boot.ini"

# optional move rootfs to USB disk (get UUID)
echo "Support moving rootfs from SD to USB disk"
echo "change boot.ini bootargs root parameter to new UUID on USB SSD/HDD partition"