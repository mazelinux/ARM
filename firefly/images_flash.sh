#!/bin/bash

sudo upgrade_tool di -b rockdev/Image-firefly/boot.img
sudo upgrade_tool di -k rockdev/Image-firefly/kernel.img
sudo upgrade_tool di -s rockdev/Image-firefly/system.img
sudo upgrade_tool di -m rockdev/Image-firefly/misc.img
sudo upgrade_tool di resource rockdev/Image-firefly/resource.img


