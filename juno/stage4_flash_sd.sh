#!/bin/bash
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


function flash_rootfs_juno()
{
    info "**************************"
	info "* Flashing filesystem..."
	info "**************************"
	# mount the sdcard partition number 1 (system) and manually copy the files
	sudo mkdir /mnt/android_usb
	info "  * mounting system partition..."
    sudo umount ${SDDEV}1
	sudo mount ${SDDEV}1 /mnt/android_usb
	info "  * copying files..."
	sudo rm -rf /mnt/android_usb/*
	sudo cp -a $ROOT_DIR/rootfs/* /mnt/android_usb/
    sudo cp $ROOT_DIR/kernel/drivers/gpu/drm/arm/hdlcd.ko /mnt/android_usb/system/lib/modules/
    sudo umount ${SDDEV}1
    sudo rm -rf /mnt/android_usb
    info "* Flashing Done..."
}


######################################################
#	stage 4. Flash the image to SD card              #
######################################################
function stage4_flash_to_sdcard()
{
	choose_sd_card
    setup_environment
    flash_rootfs_juno
}

stage4_flash_to_sdcard
