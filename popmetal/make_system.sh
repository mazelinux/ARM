#!/bin/bash

#By Maze ma
#Maze.Ma@arm.com or maze_linux@outlook.com
#this script is used to creat a system.img

#1024=1G
COUNT=4096
#####################################################################
#        Some General Use Function                                  #
#####################################################################
function info()
{
    echo -e "\033[1;40;36m$1\033[0m"
}


function error()
{
    echo -e "\033[1;31m$1\033[0m" 1>&2
}


function check_exit()
{
    if [ $? != 0 ];then
        error "something nasty happened"
        exit $?
    fi
}


#info "*******************************"
#info "* Install debootstrap and qemu*"
#info "*******************************"
#yes | apt-get install debootstrap binfmt-support pbuilder
#check_exit
#yes | apt-get install qemu qemu-user-static qemu-system
#check_exit

#info "*******************************"
#info "* Download pbuildeerc         *"
#info "*******************************"
#wget http://chipspark.com/download/file/filename/pbuilderrc
#mv pbuilderrc ~/.pbuilderrc
#sudo OS=ubuntu DIST=wily ARCH=armhf pbuilder --create
#check_exit

info "*******************************"
info "*Create system.img            *"
info "*******************************"
info "*******************************"
info "*bs = 1M , count = $COUNT      *"
info "*******************************"
dd if=/dev/zero of=system.img bs=1M count=$COUNT
check_exit
mkfs.ext4 system.img
check_exit
mkdir rootfs
mount -o loop system.img rootfs
check_exit
cd rootfs
tar xvf ../ubuntu-wily-armhf-base-new.tar.gz
cd ..
umount rootfs
check_exit


