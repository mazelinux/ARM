#!/bin/bash
#download
source ./config.sh
#####################################################################
#         stage    1      Function                                  #
#####################################################################
function checkout_android_code()
{
        info "**************************"
        info "* Checking out android...*"
        info "**************************"
#        tar -xvf "/scratch/android_aosp_orig/${AndroidEdition}.tar"
    if [[ $ANDROID_TAR != "" ]];then
        tar -xvf $ANDROID_TAR
    elif [[ $ANDROID_MIRROR != "" ]];then
        repo init -u $ANDROID_MIRROR
        repo sync -j24
    else
        repo init -u $ANDROID_GOOGLE
        repo sync -j24
    fi
#       repo init -u git://10.164.2.9/mirror/aosp/platform/manifest.git -b android-4.4.2_r1
#       repo sync -j24
#       repo init -u https://android.googlesource.com/platform/manifest.git -b android-4.4.2_r1
#       repo sync -j24
#        mv android_*/* ./
#        rm -r android_*
}


function checkout_kernel()
{
    if  [[ $KERNEL_GIT != '' ]];then
        info "**************************"
        info "* Checking out kernel... *"
        info "**************************"
        cd $ROOT_DIR
        rm -rf kernel
        git clone $KERNEL_GIT  -b $KERNEL_BRANCH kernel
        check_exit
    fi

}


function checkout_device_config()
{
    if [[ $DEVICE_GIT != "" ]];then
        info "**************************"
        info "* Checking out device/config..."
        info "**************************"
        cd $ROOT_DIR/device
        rm -rf mpd
        git clone $DEVICE_GIT  mpd
        check_exit
    fi
}


function checkout_mali()
{
        info "**************************"
        info "* Checking out mali DDK..."
        info "**************************"
        mkdir -p "$ROOT_DIR/hardware/arm/"
        cd $ROOT_DIR/hardware/arm/
#svn checkout -r $MALI_REVISION $MALI_SVN_PATH mali
        cp -rf /work/trunk mali
        check_exit 
}


function checkout_gralloc()
{
        info "**************************"
        info "* Checking out gralloc..."
        info "**************************"
        cd "$ROOT_DIR/hardware/libhardware"    
        rm -rf gralloc
        cp -r "$ROOT_DIR/hardware/arm/mali/src/egl/android/gralloc" .
        check_exit
        sed -i 's/\(#define\s*GRALLOC_ARM_UMP_MODULE\s*\)[0-9]*/\10/' "$ROOT_DIR/hardware/arm/mali/src/egl/android/gralloc/gralloc_priv.h"
        sed -i 's/\(#define\s*GRALLOC_ARM_DMA_BUF_MODULE\s*\)[0-9]*/\11/' "$ROOT_DIR/hardware/arm/mali/src/egl/android/gralloc/gralloc_priv.h"
        sed -i 's/SHARED_MEM_LIBS := libUMP/SHARED_MEM_LIBS := libion libhardware #libUMP/g' "$ROOT_DIR/hardware/arm/mali/src/egl/android/gralloc/Android.mk"
        check_exit 
}


function apply_patches() 
{
        cd $ROOT_DIR
        info "**************************"
        info "* Patching Misc Patch."
        info "**************************"
    if [[ $PATCH_GIT != "" ]];then
        rm -rf patch_tmp
        mkdir patch
        for url in `echo $PATCH_GIT`;do
            git clone $url patch_tmp
            mv patch_tmp/* patch/
            rm -rf patch_tmp
        done
        cd patch
        rm ddk.patch
        for i in `ls`; do 
            patch -p0 < $i; 
        done
        check_exit
        cd $ROOT_DIR
    fi
}


######################################################
#   stage 1. Download and patch the source code      #
######################################################
function stage1_download_source_code()
{
        checkout_android_code
        checkout_kernel
        checkout_device_config
        checkout_mali
        checkout_gralloc
        apply_patches
}


######################################################
stage1_download_source_code
