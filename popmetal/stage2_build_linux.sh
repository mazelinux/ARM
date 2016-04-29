#!/bin/bash

#By Maze ma
#Maze.Ma@arm.com or maze_linux@outlook.com

source ./config.sh

function build_kernel()
{
        info "**************************"
        info "* Building kernel..."
        info "**************************"
        cd $KERNEL_DIR
        ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE  make distclean
        check_exit
        ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE  make $KERNEL_CONFIG
        check_exit
        cp $ROOT_DIR/.config.patch ./
        patch -p0 < .config.patch
        ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE  make $KERNEL_IMAGE -j$CPU_JOB_NUM
        check_exit
        cp kernel.img $ROOT_DIR/ubuntu15.04-popmetal_test_20160216/
        check_exit
}


function build_system()
{ 
        info "**************************"
        info "* Generate system.tar.gz..."
        info "**************************"
        cd $ROOT_DIR
        ./generate_rootfs.sh $SYSTEM
}


function build_maliddk()
{ 
        info "**************************"
        info "* Building Mali so..."
        info "**************************"
        cd $MALI_DIR
        ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE KDIR=$KERNEL_DIR scons $SCONS_OPTS -j8
        check_exit
        ln -sf libGLESv1_CM.so bin/libGLESv1_CM.so.1
        ln -sf libGLESv1_CM.so.1 bin/libGLESv1_CM.so.1.1
        ln -sf libGLESv2.so bin/libGLESv2.so.2
        ln -sf libGLESv2.so.2 bin/libGLESv2.so.2.0
        #ln -sf libOpenCL.so bin/libOpenCL.so.1
        ln -sf libEGL.so bin/libEGL.so.1
        ln -sf libEGL.so.1 bin/libEGL.so.1.4
        ln -sf libmali.so bin/libwayland-egl.so
        ln -sf libwayland-egl.so bin/libwayland-egl.so.1
        ln -sf libwayland-egl.so.1 bin/libwayland-egl.so.1.0.0

        mkdir $ROOTFS_DIR/mali
        cp -r "$MALI_DIR"/bin $ROOTFS_DIR/mali/build
    
        cd "$MALI_DIR"/bin

        cp *.so* $ROOTFS_DIR/usr/lib
	#sudo cp malisc $ROOTFS_DIR/usr/local/bin
    #sudo cp *.ko $ROOTFS_DIR/lib/modules
        echo "Repack the files, this may take some time..."
        cd $rootfs
        tar -cpzf ../$rootfs"-new.tar.gz" *
}


 
function build_system_all()
{ 
        info "**************************"
        info "* Generate system.img..."
        info "**************************"
        ./make_system.sh
}
########################################################
    build_kernel
    build_system
    build_maliddk
    build_system_all
