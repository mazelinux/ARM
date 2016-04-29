#!/bin/bash

source ./config.sh
setup_environment
cd $OUT_DIR
ADB_PATH=$ROOT_DIR/out/host/linux-x86/bin/adb
echo $ADB_PATH
sudo $ADB_PATH kill-server
sudo $ADB_PATH start-server
$ADB_PATH shell stop
$ADB_PATH remount
#$ADB_PATH sync system
cd system/lib/modules/
$ADB_PATH push mali_kbase.ko /system/lib/modules/
#$ADB_PATH push mali.ko /system/lib/modules/
#cd ..

##$ADB_PATH push libMali.so /system/lib/
##$ADB_PATH push libUMP.so /system/lib/
##$ADB_PATH push libgui.so /system/lib/
#cd ./egl
cd $OUT_DIR/system/vendor/lib/egl
$ADB_PATH push libGLES_mali.so /system/lib/egl
$ADB_PATH push libGLES_mali.so /system/lib/
#$ADB_PATH push egl.cfg /system/lib/egl/
##$ADB_PATH push libEGL_mali.so /system/lib/egl/
##$ADB_PATH push libGLESv2_mali.so /system/lib/egl/
##$ADB_PATH push libGLESv1_CM_mali.so /system/lib/egl/
#$ADB_PATH push libGLES_mali.so /system/lib/egl/
#$ADB_PATH push libGLES_mali.so /system/lib/

#$ADB_PATH shell rm /system/lib/libMali.so
#$ADB_PATH shell rm /system/lib/egl/libGLESv2_mali.so
#$ADB_PATH shell rm /system/lib/egl/libGLESv1_CM_mali.so
#$ADB_PATH shell rm /system/lib/egl/libEGL_mali.so
cd ../hw
$ADB_PATH push gralloc.firefly.so /system/lib/hw
$ADB_PATH shell chmod 644 /system/lib/modules/*
$ADB_PATH shell chmod 644 /system/lib/*
