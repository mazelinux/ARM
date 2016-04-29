#!/bin/bash


#####################################################################
#        Config                                                     #
#####################################################################
    ROOT_DIR=$(pwd)
    USERNAME=$(whoami)
    AndroidEdition=android_6.0.0_r1
    AndroidPlatform=firefly_rk3288
    ARCH=arm
    SEC_PRODUCT=firefly
    CPU_JOB_NUM=$(grep -c processor /proc/cpuinfo)
    PROFILE_SCONS=firefly-release-m
    CROSS_COMPILE=arm-eabi-
    DEVICE_DIR=$ROOT_DIR/device
    DEVICE_TREE=
    DEVICE_GIT=device.git
    DEVICE_BRANCH=master
    DNS_UPDATE=
    KERNEL_DIR=$ROOT_DIR/kernel
    KERNEL_GIT=kernel.git
    KERNEL_BRANCH=master
    KERNEL_CONFIG=firefly-rk3288-linux_defconfig
    KERNEL_IMAGE=firefly-rk3288.img
    LUNCH_ENG=firefly-eng
    OUT_DIR=$SEC_PRODUCT
    TOOL_GIT=tool.git
    TOOL_BRANCH=master
    GENERATE_FLASH_SCRIPT_GIT=script.git
    DDK_VENDOR_GIT=ssh://driver
    TARGET_PLATFORM=
    UBOOT_DIR=
####################################################################
#   ANDROID_CODE_CHOSE                                             #
####################################################################
    ANDROID_GOOGLE="https://android.googlesource.com/platform/manifest -b android-6.0.0_r1"
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

function setup_environment()
{
    cd $ROOT_DIR
    . build/envsetup.sh
    lunch $LUNCH_ENG
}


#####################################################################
#         stage    1      Function                                  #
#####################################################################
function confirm_android_platform()
{
        info "*******************************"
        info "* Please check your configure *"
        info "*******************************"
        echo "Android Edition is $AndroidEdition and Platform is $AndroidPlatform"
        echo "CONFIG_DDK=$CONFIG_DDK"
}

confirm_android_platform

