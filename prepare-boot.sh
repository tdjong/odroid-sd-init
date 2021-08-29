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
# shellcheck source=settings.ini
source "${SCRIPT_DIR}/settings.ini" 

if [ ! -d "$MNTDIR/boot" ]; then
  echo "No root partition mounted on $MNTDIR."
  ls $MNTDIR
  exit 1
fi

cd $MNTDIR/boot/
ls -l *ini*

echo "Odroid Ubuntu has bootargs in boot.ini"
echo << EOF
setenv containers "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"

# Boot Args
setenv bootargs "console=tty1 console=ttySAC2,115200n8 root=UUID=e139ce78-9841-40fe-8823-96a304a09859 rootwait \
                ro fsck.repair=yes net.ifnames=0 ${videoconfig} ${hdmi_phy_control} ${hid_quirks} smsc95xx.macaddr=${macaddr} ${external_watchdog} ${containers}"
EOF
