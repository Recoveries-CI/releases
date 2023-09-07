#!/bin/bash

export GITHUB_USER="Recoveries-CI"
export GITHUB_EMAIL="fernandoaju78@gmail.com"

export device="OP5x5T"
export OEM="oneplus"
export DT_PATH="device/$OEM/$device/"
export DT_LINK="https://gitlab.com/faoliveira78/device_oneplus_cheeseburger_dumpling.git -b fox_12.1"

export ROM="OrangeFox"
export ROM_DIR="${WORKSPACE}/../OFOX"
export manifest_url="https://gitlab.com/OrangeFox/sync.git"
export rom_vendor_name="twrp"
export branch="fox_12.1"

export ccache="true"
export ccache_size="100"

export jenkins="true"
#export sync="true"

export release_repo="Recoveries-CI/releases"
export release_branch="ofox-op5_t"

export timezone="BRT"

# Magisk
## Use the Latest Release of Magisk for the OrangeFox addon
export OF_USE_LATEST_MAGISK=true

#export FOX_VERSION="R11.1_5-dyn"
#export ONEPLUS_DYNAMIC="true"