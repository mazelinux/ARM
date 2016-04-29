#!/bin/bash

set -e

(( EUID == 0 )) || die '\nThis script must be run with root privileges'

#ubuntu_core="ubuntu-core-14.04.4-core-armhf.tar.gz"
#ubuntu_core="ubuntu-core-15.04-core-armhf.tar.gz"
#ubuntu_core="ubuntu-vivid-armhf-base.tar.gz"
ubuntu_core="ubuntu-wily-armhf-base.tgz"

rootfs=`basename $ubuntu_core .tgz`

chroot_cmd="chroot $rootfs"

# Extract root filesystem
#rm -rf $rootfs
if [ ! -d "$rootfs" ]; then  
    mkdir "$rootfs"  
fi

tar -xf $ubuntu_core -C $rootfs

if [ ! -f $FILE ]; then
    echo "You need to install qemu-static."
    exit 1
fi

#cp /usr/bin/qemu-arm-static $rootfs/usr/bin

# the qemu built by myself
cp qemu-arm $rootfs/usr/bin/qemu-arm-static

#: <<'COMMENTOUT'

#echo $rootfs-sources.list
#
# Install custom sources list
#cp extras/$rootfs-sources.list $rootfs/etc/apt/sources.list

# DNS servers
cp extras/resolv.conf $rootfs/etc/

export DEBIAN_FRONTEND=noninteractive

# Generating locales
$chroot_cmd locale-gen en_US en_US.UTF-8 en_GB en_GB.UTF-8
#$chroot_cmd dpkg-reconfigure locales

# need to be there
$chroot_cmd touch /etc/init.d/modemmanager
$chroot_cmd touch /etc/init.d/gssd
$chroot_cmd touch /etc/init.d/idmapd

# Upgrade the filesystem
$chroot_cmd apt-get -y update
$chroot_cmd apt-get -y upgrade

$chroot_cmd apt-get -y install apt-utils

# Install necessary packages
$chroot_cmd apt-get -y install bash-completion
$chroot_cmd apt-get -y install isc-dhcp-client network-manager
$chroot_cmd apt-get -y install gdb strace
$chroot_cmd apt-get -y install openssh-server openssh-client sshfs
#$chroot_cmd apt-get -y install parted gdisk
$chroot_cmd apt-get -y install iputils-ping net-tools
$chroot_cmd apt-get -y install fbset
$chroot_cmd apt-get -y install less
$chroot_cmd apt-get -y install nfs-common
#$chroot_cmd apt-get -y install samba smbclient
$chroot_cmd apt-get -y install gcc g++ make
$chroot_cmd apt-get -y install emacs vim
$chroot_cmd apt-get -y install git subversion
$chroot_cmd apt-get -y install gdbserver
$chroot_cmd apt-get -y install build-essential
$chroot_cmd apt-get -y install cmake scons autoconf libtool pkg-config

#$chroot_cmd apt-get -y install lubuntu-desktop

# for building xserver
$chroot_cmd apt-get -y install libgl1-mesa-dev libgcrypt11-dev libxcb-keysyms1-dev flex bison

# X11 packages
$chroot_cmd apt-get -y install xserver-xorg xinit
$chroot_cmd apt-get -y install xorg-dev libxcb-dri2-0
$chroot_cmd apt-get -y install openbox
$chroot_cmd apt-get -y install xfce4-terminal

$chroot_cmd apt-get -y install libudev-dev
$chroot_cmd apt-get -y install xutils-dev libnih-dev libnih-dbus-dev

#COMMENTOUT

# Allow logging in via serial
cp extras/tty*.conf $rootfs/etc/init/
cp extras/securetty $rootfs/etc/

cp extras/fstab $rootfs/etc/
cp extras/interfaces $rootfs/etc/network/

sed -i 's|PermitRootLogin.*|PermitRootLogin yes|' $rootfs/etc/ssh/sshd_config
#sed -i 's|RUN=no|RUN=yes|' $rootfs/etc/default/saned

# Install xinit script
cp extras/xinitrc $rootfs/root/.xinitrc

# egl/gles headers
cp -r extras/khronos/* $rootfs/usr/include

# Change the root password
root_pw=root
$chroot_cmd sh -c "echo 'root\n$root_pw' | passwd root"
echo "** You can login with username 'root' and password '$root_pw'"


