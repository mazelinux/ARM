#!/bin/bash


source ./config.sh
#####################################################################
#         stage    2      Function                                  #
#####################################################################
function setup_environment()
{
        info "**************************"
        info "* Set Environment..."
        info "**************************"
        cd $ROOT_DIR
        source build/envsetup.sh
        lunch $LUNCH_ENG
}


function build_kernel()
{
        info "**************************"
        info "* Building kernel..."
        info "**************************"
        cd $KERNEL_DIR
        ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE  make distclean
        ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE  make $KERNEL_CONFIG
        CONFIG_MALI_PLATFORM_THIRDPARTY_NAME="rk3"
        cd drivers/gpu/arm/midgard/platform  
        ln -s rk rk3 
        cd -
        ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make $KERNEL_IMAGE -j$CPU_JOB_NUM
}


function build_ddk()
{
        info "**************************"
        info "* Build DDK..."
        info "**************************"
        info "**************************"
        info "* If you have some trouble on this step,try again..."
        info "**************************"
        cd $ROOT_DIR/vendor/arm/product
        rm Android.mk
        cp $ROOT_DIR/kernel/drivers/gpu/arm/midgard/mali_base_hwconfig.h $ROOT_DIR/vendor/arm/product/
            ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE KDIR=$KERNEL_DIR scons profile=firefly-release-m -j8  
        mm -B -j9
        cd $ROOT_DIR
        mkdir -p $OUT_DIR/system/lib/modules/
        chmod 644 $ROOT_DIR/vendor/arm/product/kernel/drivers/gpu/arm/midgard/mali_kbase.ko
        check_exit
        cp $ROOT_DIR/vendor/arm/product/kernel/drivers/gpu/arm/midgard/mali_kbase.ko $OUT_DIR/system/lib/modules/
}


function build_android()
{
        info "**************************"
        info "* Building Android ..."
        info "**************************"
        START_TIME=`date +%s`
        cd $ROOT_DIR
        mm  -j$CPU_JOB_NUM
        check_exit
        END_TIME=`date +%s`
        let "ELAPSED_TIME=$END_TIME-$START_TIME"
        echo "Total compile time is $ELAPSED_TIME seconds"
}


function build_gralloc()
{
        cd $ROOT_DIR/vendor/arm/product 
        mm -B -j9
        GRALLOC_FB_SWAP_RED_BLUE=1 GRALLOC_DEPTH=GRALLOC_32_BITS mm -B -j9
}


######################################################
#   stage 2. Build Kernel Android and DDK            #
######################################################
function stage2_build_source_code()
{
        setup_environment
        build_kernel
        build_ddk
        build_android
        build_gralloc
}
######################################################
stage2_build_source_code
