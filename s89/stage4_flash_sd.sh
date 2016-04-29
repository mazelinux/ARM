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

function flash_uboot()
{
	if [[ $UBOOT_GIT != "" ]];then
		info "**************************"
		info "* Flashing u-boot..."
		info "**************************"
            cd "$UBOOT_DIR/sd_fuse"
            make
            ./c210-fusing.sh $SDDEV
            check_exit
	fi
}

function flash_kernel_ramdisk()
{
	info "**************************"
	info "* Flashing kernel and ramdisk image..."
	info "**************************"
    sudo mkdir /mnt/android_sdcard
	sudo mount ${SDDEV}1 /mnt/android_sdcard
	sudo cp $ROOT_DIR/kernel/m8boot.img /mnt/android_sdcard/
	sudo chmod -R 777 /mnt/android_sdcard/
	sudo umount ${SDDEV}1
    sudo rm -rf /mnt/android_sdcard
}

function flash_file_system()
{
	info "**************************"
	info "* Flashing filesystem..."
	info "**************************"
	# mount the sdcard partition number 2 (system) and manually copy the files
	sudo mkdir /mnt/android_sdcard
	info "  * mounting system partition..."
	sudo mount ${SDDEV}2 /mnt/android_sdcard
	info "  * copying files..."
	sudo rm -rf /mnt/android_sdcard/*
	sudo cp -a $OUT_DIR/system/* /mnt/android_sdcard/
	info "  * setting permissions..."
	sudo chmod -R 777 /mnt/android_sdcard/
	sudo chmod 750 /mnt/android_sdcard/build.prop
	sudo chmod 644 /mnt/android_sdcard/lib/modules/mali.ko
	info "  * unmounting system partition (can take a while)..."
	sudo umount ${SDDEV}2

	# mount the sdcard partition number 3 (data) and manually copy the files
	info "  * mounting data partition..."
	sudo mount ${SDDEV}3 /mnt/android_sdcard
	info "  * copying files..."
	sudo rm -rf /mnt/android_sdcard/*
	sudo cp -a $OUT_DIR/data/* /mnt/android_sdcard/
	cd /mnt/android_sdcard/
	sudo mkdir dalvik-cache property app app-asec app-lib app-private data misc drm local

	info "  * setting permissions..."
	sudo chmod -R 777 /mnt/android_sdcard/
	info "  * unmounting data partition (can take a while)..."
	cd $ROOT_DIR
	sudo umount ${SDDEV}3
	sudo rm -rf /mnt/android_sdcard
}


######################################################
#	stage 4. Flash the image to SD card              #
######################################################
function stage4_flash_to_sdcard()
{
      choose_sd_card
	  flash_uboot
	  flash_kernel_ramdisk
	  flash_file_system
}

stage4_flash_to_sdcard
