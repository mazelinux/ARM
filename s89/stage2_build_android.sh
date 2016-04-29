#!/bin/bash
#build_Android_BSP
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
        ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE  make $KERNEL_IMAGE -j$CPU_JOB_NUM
        check_exit
    for i in `echo $DEVICE_TREE`;do
        ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE make $i
    done
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


function mali_generate_android_mk()
{
        info "**************************"
        info "* Generate Android.mk according to VARIANT..."
        info "**************************"
        cd "$ROOT_DIR/hardware/arm/mali"
        rm -rf Android.mk
        TARGET_PLATFORM=odroidq
        TARGET_TOOLCHAIN=arm-linux-gcc
        TARGET_PLATFORM=$TARGET_PLATFORM TARGET_TOOLCHAIN=$TARGET_TOOLCHAIN CONFIG=$CONFIG_DDK VARIANT=$VARIANT make
        check_exit
}


function build_gralloc()
{
        info "**************************"
        info "* Building Gralloc ......."
        info "**************************"
        cd "$ROOT_DIR/system/core/libion"
        mm -j$CPU_JOB_NUM
        cd "$ROOT_DIR/hardware/arm/mali/src/egl/android/gralloc"
        mm -j$CPU_JOB_NUM
        check_exit
}


function build_mali_ko()
{
        info "**************************"
        info "* Building mali.ko..."
        info "**************************"
        cd $ROOT_DIR/hardware/arm/mali/src/devicedrv/mali
        USING_DT=0
        USING_UMP=0
        ARCH=arm
        cp -r $ROOT_DIR/kernel/arch/arm/mach-exynos/include/mach/ $ROOT_DIR/kernel/include/
        cp -r $ROOT_DIR/kernel/arch/arm/plat-samsung/include/plat/ $ROOT_DIR/kernel/include/
        TARGET_PLATFORM=$MALI_KO_TARGET_PLATFORM ARCH=$ARCH KDIR=$KERNEL_DIR BUILD=$CONFIG_DDK USING_UMP=$USING_UMP USING_DT=$USING_DT CROSS_COMPILE=$CROSS_COMPILE make -j$CPU_JOB_NUM
        check_exit
        rm -rf $ROOT_DIR/kernel/include/mach/
        rm -rf $ROOT_DIR/kernel/include/plat/
        chmod 600 $ROOT_DIR/hardware/arm/mali/src/devicedrv/mali/mali.ko
    if [[ ! -d "$OUT_DIR/system/lib/modules" ]];then
        mkdir -p $OUT_DIR/system/lib/modules/
    fi
        cp $ROOT_DIR/hardware/arm/mali/src/devicedrv/mali/mali.ko $OUT_DIR/system/lib/modules/
}


function retrive_ddk_build()
{
        info "**************************"
        info "* Building DDK ..."
        info "**************************"
        cd $ROOT_DIR
        build_mali_ko
}


function add_dns_tool()
{
        info "**************************"
        info "* Add_dns_tool ..."
        info "**************************"
    if [[ $DNS_UPDATE != "" ]];then
        cp /scratch/android_aosp_orig/dns_tool/dnsproxy2 $OUT_DIR/system/bin/
        cp /scratch/android_aosp_orig/dns_tool/20dnsproxy2 $OUT_DIR/system/bin/
    fi
}



######################################################
#   stage 2. Build Kernel Android and DDK            #
######################################################
function stage2_build_source_code()
{
        setup_environment
        mali_generate_android_mk
        build_kernel
        retrive_ddk_build
        build_android
        build_gralloc
        add_dns_tool
}


######################################################
stage2_build_source_code
