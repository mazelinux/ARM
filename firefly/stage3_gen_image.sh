#!/bin/bash


source ./config.sh
#####################################################################
#         stage    3      Function                                  #
#####################################################################
function gengerate_images()
{
        cd $ROOT_DIR
        source images_make.sh
        check_exit
}


function install_flashtool()
{
        tar xf Linux_Upgrade_Tool_v1.2.tar.gz
        cd Linux_Upgrade_Tool_v1.2
        sudo mv upgrade_tool /usr/local/bin
        sudo chown root:root /usr/local/bin/upgrade_tool
}


######################################################
#   stage 3. Generate images                         #
######################################################
function stage3_generate_images()
{
        setup_environment
        gengerate_images
        install_flashtool
}


######################################################
stage3_generate_images
