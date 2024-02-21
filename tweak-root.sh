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

if [ ! -d "$MNTDIR/root" ]; then
  echo "No root partition mounted on $MNTDIR."
  ls "$MNTDIR"
  exit 1
fi
MNTDIR=$MNTDIR/root
cat "$MNTDIR/etc/os-release"
# shellcheck source=/dev/null
source "$MNTDIR/etc/os-release"

cat << EOF > remotePrepare.sh 
#!/bin/bash
# Goal: Allow root to SSH with your authorized keys
# This script will be used in chrooted environment
mkdir /root/.ssh
# Download, or otherwise add to the authorized_keys file, your public keys
# Replace the URL with the path to your own public keys
touch /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

# Add a local user, and put them in the sudo group
# Change the group and user to whatever you desire
groupadd ${GitHubUser}
useradd -g ${GitHubUser} -G sudo -m -u 1000 ${GitHubUser} -s /bin/bash

# we have not set a password
# Allow the wheel group (with your local user) to use sudo without a password
echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/91-sudo-nopasswd

# Add your authorized keys
# Change the homedir and URL as you've done above
mkdir /home/${GitHubUser}/.ssh
touch /home/${GitHubUser}/.ssh/authorized_keys
chmod 700 /home/${GitHubUser}/.ssh
chmod 600 /home/${GitHubUser}/.ssh/authorized_keys
chown -R ${GitHubUser}.${GitHubUser} /home/${GitHubUser}/.ssh/
EOF
echo "OS info host:"
uname -a
cat /etc/os-release
echo "Assuming qemu-user-static is installed and running"
echo "Run next commands inside qemu on sdcard image"
sudo chroot "$MNTDIR" /bin/uname -a
sudo chroot "$MNTDIR" cat /etc/os-release
sudo chroot "$MNTDIR" bash < remotePrepare.sh

echo "Get and install authorized keys in boot image"
curl "https://github.com/${GitHubUser}.keys" -o authorized_keys
sudo cp authorized_keys "$MNTDIR/root/.ssh/authorized_keys"
sudo cp authorized_keys "$MNTDIR/home/${GitHubUser}/.ssh/authorized_keys"

echo "Checking installation of authorized keys"
sudo ls -l "$MNTDIR/root/.ssh/authorized_keys"
sudo ls -l "$MNTDIR/home/${GitHubUser}/.ssh/authorized_keys"
