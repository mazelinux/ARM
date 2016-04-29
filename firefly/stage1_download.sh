#!/bin/bash

source ./config.sh
#####################################################################
#         stage    1      Function                                  #
#####################################################################
function checkout_android_code()
{
        info "**************************"
        info "* Checking out Android... *"
        info "**************************"
        if [[ $ANDROID_TAR != "" ]];then
        tar -zxvf $ANDROID_TAR
        elif [[ $ANDROID_MIRRORS != "" ]];then
        repo init -u $ANDROID_MIRRORS
        repo sync -j24
        else
        repo init -u  $ANDROID_GOOGLE
        repo sync -j24
        fi
}


function checkout_kernel()
{
    if  [[ $KERNEL_GIT != '' ]];then
        info "**************************"
        info "* Checking out kernel... *"
        info "**************************"
        cd $ROOT_DIR
###1
#       git clone $KERNEL_GIT kernel
###1 
        git clone $KERNEL_GIT -b $KERNEL_BRANCH kernel
    fi
}


function checkout_uboot()
{
        info "**************************"
        info "* Checking out uboot..."
        info "**************************"
        cd $ROOT_DIR
        mv bootable/recovery/Android.mk bootable/recovery/Android.mk_
}


function checkout_device_config()
{
    if [[ $DEVICE_GIT != "" ]];then
        info "**************************"
        info "* Checking out device/config..."
        info "**************************"
        cd $DEVICE_DIR
###1
#       git clone ANDROID_CONFIG_GIT rockchip
###1
        git clone $DEVICE_GIT -b $DEVICE_BRANCH rockchip
        check_exit
        fi
}


function checkout_for_firefly()
{ 
        info "**************************"
        info "* Checking out for firefly..."
        info "**************************"
        cd $ROOT_DIR
        git clone $TOOL_GIT -b $TOOL_BRANCH rkst
        check_exit
        git clone $GENERATE_FLASH_SCRIPT_GIT script
        check_exit
        mv  script/* ./
        rm -rf script/
}

function checkout_ddk()
{
        info "**************************"
        info "* Checking out DDK..."
        info "**************************"
        cd $ROOT_DIR
        mkdir -p $ROOT_DIR/vendor/
        cd $ROOT_DIR/vendor/
        git clone $DDK_VENDOR_GIT arm
        check_exit
}

######################################################
#   stage 1. Download and patch the source code      #
######################################################
function stage1_download_source_code()
{
#checkout_android_code
#checkout_device_config
#checkout_uboot
#checkout_kernel
#checkout_for_firefly
        checkout_ddk
}


######################################################
stage1_download_source_code
