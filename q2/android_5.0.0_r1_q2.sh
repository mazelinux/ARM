#!/bin/bash
./stage1_download.sh
./stage2_build_android.sh
./stage3_gen_image.sh
./stage4_flash_sd.sh
