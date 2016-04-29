#!/bin/bash
#get images
source ./config.sh
##############################################################################
#		Flash Android To SDCard
##############################################################################
function choose_sd_card()
{
	info "*****************************"
	info "* Please choose your SDCard *"
	info "*****************************"

	ls /dev/sd* | grep sd.$ | xargs -I {} echo -e "\t{}"
	read -p "Your choice is : /dev/" -e SDDEV
	SDDEV=/dev/$(echo $SDDEV | sed 's/^\s*//g' | sed 's/\s*$//g' | tr 'A-Z' 'a-z')
}


function confirm_mmc_device()
{
	info "**************************"
	info "* Confirming device is correct or not..."
	info "**************************"
	sudo parted $SDDEV -s print
	read -p "Are you sure to use $SDDEV device? [y/N] "
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		exit 1
	fi
}


function make_partitions_juno()
{
	info "**************************"
	info "* Making partitions on sdcard..."
	info "**************************"
  sudo umount ${SDDEV}* 2>/dev/null || true
	sudo parted $SDDEV -s rm 1 || true
	sudo parted $SDDEV -s rm 2 || true
	sudo parted $SDDEV -s rm 3 || true
	SD_CARD_SIZE=`sudo fdisk -l $SDDEV | grep "Disk /dev" | cut -f5 -d" "`
	SD_CARD_END=$[ $SD_CARD_SIZE / 1024 / 1024 ]
  sudo parted $SDDEV -s mkpart primary ext4 32.0MB 4000MB
	sudo parted $SDDEV -s mkpart primary ext4 4000MB 6000MB
	sudo parted $SDDEV -s mkpart primary ext4 6000MB ${SD_CARD_END}MB
	sudo mkfs.ext4  ${SDDEV}1
	sudo mkfs.ext4  ${SDDEV}2
	sudo mkfs.ext4  ${SDDEV}3
	info "Partition table:"
	sudo parted $SDDEV -s print
}

function make_rootfs_juno()
{
	info "**************************"
	info "* Making ROOTFS For Juno  "
	info "**************************"
  cd $ROOT_DIR/build/tools/fs_get_stats/
  mm -j$CPU_JOB_NUM
  cd $ROOT_DIR
  if [[ ! -d 'rootfs' ]];then
     mkdir rootfs
  else
     sudo rm -rf rootfs/*
  fi
  chmod 777 rootfs
  cd rootfs
  cp -rf $OUT_DIR/root fs
  cp -rf $OUT_DIR/system fs/
  sudo $ROOT_DIR/build/tools/mktarball.sh $ROOT_DIR/out/host/linux-x86/bin/fs_get_stats fs "*" rootfs  rootfs.tar.bz2
  sudo bzip2 -d rootfs.tar.bz2
  sudo tar -xvf rootfs.tar
  rm -rf fs/
  sudo rm rootfs.tar
}


######################################################
#	stage 3. generate the image                      #
######################################################
function stage3_generate_image()
{
	choose_sd_card
	confirm_mmc_device
	setup_environment
    make_partitions_juno
    make_rootfs_juno
}
stage3_generate_image
