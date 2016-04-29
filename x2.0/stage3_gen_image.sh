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

function make_partitions()
{
	info "**************************"
	info "* Making partitions on sdcard..."
	info "**************************"
	sudo umount ${SDDEV}* 2>/dev/null || true
	sudo parted $SDDEV -s rm 1 || true
	sudo parted $SDDEV -s rm 2 || true
	sudo parted $SDDEV -s rm 3 || true
	sudo parted $SDDEV -s rm 4 || true
	SD_CARD_SIZE=`sudo fdisk -l $SDDEV | grep "Disk /dev" | cut -f5 -d" "`
	SD_CARD_END=$[ $SD_CARD_SIZE / 1024 / 1024 ]
	sudo parted $SDDEV -s mkpart primary fat32 6000MB ${SD_CARD_END}MB
	sudo parted $SDDEV -s mkpart primary ext4 32.0MB 2000MB
	sudo parted $SDDEV -s mkpart primary ext4 2000MB 4000MB
	sudo parted $SDDEV -s mkpart primary ext4 4000MB 6000MB
    sudo mkfs.vfat  ${SDDEV}1
    sudo mkfs.ext4  ${SDDEV}2
    sudo mkfs.ext4  ${SDDEV}3
    sudo mkfs.ext4  ${SDDEV}4
	info "Partition table:"
	sudo parted $SDDEV -s print
}


function make_ramdisk_image()
{
	info "**************************"
	info "* Make ramdisk image for u-boot..."
	info "**************************"
	cd $OUT_DIR
    mkimage -A arm -O linux -T ramdisk -C none -a 0x40800000 -n "ramdisk" -d ramdisk.img ramdisk-uboot.img
    check_exit
}


######################################################
#	stage 3. generate the image                      #
######################################################
function stage3_generate_image()
{
	setup_environment
	choose_sd_card
	confirm_mmc_device
	make_partitions
	make_ramdisk_image
}

stage3_generate_image
