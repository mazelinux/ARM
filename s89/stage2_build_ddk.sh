#!/bin/bash
source ./config.sh
        

#####################################################################
#         stage    3      Function                                  #
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


function mali_build_ddk()
{
        cd "$ROOT_DIR/hardware/arm/mali"
        mm -B -j$CPU_JOB_NUM
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


########################################################################
        setup_environment
        mali_generate_android_mk
        mali_build_ddk
        build_mali_ko
        build_gralloc
