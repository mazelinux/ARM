#!/bin/bash
#download
source ./config.sh


#####################################################################
#         stage    2      Function                                  #
#####################################################################
function checkout_android_code()
{
        info "**************************"
        info "* Checking out android...*"
        info "**************************"
        tar -zxvf "/scratch/android_aosp_orig/${AndroidEdition}.tar.gz"
    if [[ $ANDROID_TAR != "" ]];then
        tar -zxvf $ANDROID_TAR
    elif [[ $ANDROID_MIRROR != "" ]];then
        repo init -u $ANDROID_MIRROR
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
        rm -rf kernel
        git clone $KERNEL_GIT -b $KERNEL_BRANCH kernel
        check_exit
    fi
}


function checkout_uboot()
{
    if [[ $UBOOT_GIT != "" ]];then
        info "**************************"
        info "* Checking out uboot..."
        info "**************************"
        cd $ROOT_DIR
        rm -rf uboot u-boot
        git clone $UBOOT_GIT uboot
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
        rm -rf hardkernel
        git clone $DEVICE_GIT -b $DEVICE_BRANCH hardkernel
        check_exit
        EXYNOS4_GIT=/scratch/git/device_samsung_exynos4_lollipop.git
        [ ! -f $ROOT_DIR/device/samsung ] && mkdir -p $ROOT_DIR/device/samsung
        cd $ROOT_DIR/device/samsung
        rm -rf exynos4
        git clone $EXYNOS4_GIT exynos4
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
#        svn checkout -r $MALI_REVISION $MALI_SVN_PATH mali
        cp -rf /work/trunk/ mali
        check_exit 
}


function checkout_gralloc()
{
        info "**************************"
        info "* Checking out gralloc..."
        info "**************************"
        cd "$ROOT_DIR/hardware/libhardware"
        rm -rf modules/gralloc
        ln -s "$ROOT_DIR/hardware/arm/mali/src/egl/android/gralloc" modules/
        check_exit 
}


function apply_patches() 
{
        info "**************************"
        info "* Applying patches..."
        info "**************************"
        cd $ROOT_DIR
    if [[ $PATCH_GIT != "" ]];then
        rm -rf patch_tmp
        mkdir patch
        for url in `echo $PATCH_GIT`;do
        git clone $url patch_tmp
        mv patch_tmp/* patch/
        rm -rf patch_tmp
        done
        cd patch
        cp hdmi.patch $ROOT_DIR/system/vold
        cp hdminative.patch $ROOT_DIR/frameworks/native
        cd $ROOT_DIR
        patch -p1 < patch/videodev2.patch
        cd $ROOT_DIR/system/vold
        patch -p1 < hdmi.patch
        check_exit
        cd $ROOT_DIR/frameworks/native
        patch -p1 < hdminative.patch
        check_exit
        cd $ROOT_DIR
    fi
        check_exit 
}
                       

######################################################
#   stage 2. Download and patch the source code      #
######################################################
function stage2_download_source_code()
{
        checkout_android_code
        checkout_kernel
        checkout_uboot
        checkout_device_config
        checkout_mali
        checkout_gralloc
        apply_patches
}
######################################################
stage2_download_source_code
