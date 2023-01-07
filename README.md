# Target: Odroid HC1 as docker based NAS

Low power Arm device with Nextcloud
Based on Docker, Docker-compose
Future release maybe on k3s (kubernetes)

## Parts

* Odroid HC1 micropc with power adapter (32 bits armv7 CPU)
* 8+ GB MicroSD for boot
* HDD / SSD for data storage and future root filesystem
* microsd adapter for PC
* Debian/Ubuntu based PC

## Preparation

* Download latest Ubuntu version for Odroid
  https://wiki.odroid.com/odroid-xu4/os_images/linux/ubuntu_5.4/minimal/20210112
* Install qemu-user-static on PC (Windows with WSL2 or native Debian based Linux distribution)
* Modify raw image from Linux distributie (prepare-raw.sh IMAGEFILE)
  * Configure SSHD server
  * Create local non-root user (no password set, passwordless login/sudo required)
  * Allow non-root user to sudo
  * Add SSH authorized keys for easy access (ansible?)
* Write to microSD
* Boot Odroid from microSD

## Inrichting en ansible ready maken

* ssh to GitHubUser on Odroid
* sudo apt update; sudo apt upgrade -y; sudo apt dist-upgrade -y

## Move root to SSD / HDD instead of MicroSD

https://wiki.odroid.com/odroid-xu4/software/ubuntu_nas/02_mount_hdds

## NAS software via ansible / docker of podman

## Lessons learned

* Armbian contains a subset of Ubuntu
* Usb-to-SATA does not detect some drives in combination with some kernel (options)

## Bronnen

* https://wiki.odroid.com/odroid-xu4/software/ubuntu_nas/
* https://opensource.com/article/20/5/disk-image-raspberry-pi
* https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi#1-overview
* https://opensource.com/article/20/6/kubernetes-raspberry-pi
* https://blog.radwell.codes/2021/05/kubernetes-on-raspberry-pi/

Bash tricks

* https://www.cyberciti.biz/tips/bash-shell-parameter-substitution-2.html
* https://tldp.org/LDP/abs/html/here-docs.html
* 