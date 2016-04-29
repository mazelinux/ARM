#!/bin/bash

source ./config.sh
setup_environment
info "**************************"
info "* Retrive DDK..."
info "**************************"
cd $ROOT_DIR/vendor/arm/product 
info "**************************"
info "* Build DDK..."
info "**************************"
info "**************************"
info "* If you have some trouble on this step,try again..."
info "**************************"
cp $ROOT_DIR/kernel/drivers/gpu/arm/midgard/mali_base_hwconfig.h $ROOT_DIR/vendor/arm/product/
ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE KDIR=$KERNEL_DIR scons profile=$PROFILE_SCONS -j8  
mm  -j$CPU_JOB_NUM
cd $ROOT_DIR
mkdir -p $OUT_DIR/system/lib/modules/
chmod 644 $ROOT_DIR/vendor/arm/product/kernel/drivers/gpu/arm/midgard/mali_kbase.ko
check_exit
cp $ROOT_DIR/vendor/arm/product/kernel/drivers/gpu/arm/midgard/mali_kbase.ko $OUT_DIR/system/lib/modules/
