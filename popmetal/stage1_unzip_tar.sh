#!/bin/bash
#By Maze ma
#Maze.Ma@arm.com or maze_linux@outlook.com

source ./config.sh
info "**************************"
info "* Unzip all the tar packages..."
info "**************************"

unzip $ALL_TAR
check_exit
tar zxvf $KERNEL_TAR
check_exit
tar zxvf $MALI_TAR
check_exit

info "**************************"
info "* Then you can run build_linux.sh..."
info "**************************"
