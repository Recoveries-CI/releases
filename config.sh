#!/bin/bash

export GITHUB_USER="Recoveries-CI"
export GITHUB_EMAIL="fernandoaju78@gmail.com"

export device="cheesedump"

export ROM="PBRP"
export ROM_DIR="${WORKSPACE}/../${ROM}"
export local_manifest_url="https://raw.githubusercontent.com/faoliveira78/manifests/master/pbrp/official.xml"
export manifest_url="https://github.com/PitchBlackRecoveryProject/manifest_pb"
export rom_vendor_name="omni"
export branch="android-14.0"

export ccache="true"
export ccache_size="100"

export jenkins="true"
#export sync="true"

export release_repo="Recoveries-CI/releases"
export release_branch="pbrp-op5_t"

export timezone="BRT"

#export PB_MAIN_BUILD="-UNOFFICIAL"
#export pb_version="4.0-dyn"
#export ONEPLUS_DYNAMIC="true"