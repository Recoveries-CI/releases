#!/bin/bash

export outdir="${ROM_DIR}/out/target/product/${device}"
BUILD_START=$(date +"%s")
echo "Build started for ${device}"
if [ "${jenkins}" == "true" ]; then
    telegram -M "Build ${BUILD_DISPLAY_NAME} started for ${device}: [See Progress](${BUILD_URL}console)"
else
    telegram -M "Build started for ${device}"
fi

source "${my_dir}/config.sh"

# Change to the Source Directry
cd $ROM_DIR

# Sync Branch (will be used to fix legacy build system errors)
if [ -z "$SYNC_BRANCH" ]; then
    export SYNC_BRANCH=$(echo ${branch} | cut -d_ -f2)
fi

if [ "${ccache}" == "true" ] && [ -n "${ccache_size}" ]; then
    export USE_CCACHE=1
    ccache -M "${ccache_size}G"
elif [ "${ccache}" == "true" ] && [ -z "${ccache_size}" ]; then
    echo "Please set the ccache_size variable in your config."
    exit 1
fi

# Empty the VTS Makefile
if [ "$branch" = "fox_11.0" ]; then
    rm -rf frameworks/base/core/xsd/vts/Android.mk
    touch frameworks/base/core/xsd/vts/Android.mk 2>/dev/null || echo
fi
# Prepare the Build Environment
source build/envsetup.sh

export ALLOW_MISSING_DEPENDENCIES=true
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
export LC_ALL=C

# Default Build Type
if [ -z "$FOX_BUILD_TYPE" ]; then
    export FOX_BUILD_TYPE="Unofficial-CI"
fi

# Default Maintainer's Name
[ -z "$OF_MAINTAINER" ] && export OF_MAINTAINER="Unknown"

# Set BRANCH_INT variable for future use
BRANCH_INT=$(echo $SYNC_BRANCH | cut -d. -f1)

# Magisk
if [[ $OF_USE_LATEST_MAGISK = "true" || $OF_USE_LATEST_MAGISK = "1" ]]; then
	echo "Using the Latest Release of Magisk..."
	export FOX_USE_SPECIFIC_MAGISK_ZIP=$("ls" $HOME/Magisk/Magisk*.zip)
fi

# Legacy Build Systems
if [ $BRANCH_INT -le 6 ]; then
    export OF_DISABLE_KEYMASTER2=1 # Disable Keymaster2
    export OF_LEGACY_SHAR512=1 # Fix Compilation on Legacy Build Systems
fi

lunch "${rom_vendor_name}_${device}-eng"
m clean && m clobber -j$(nproc --all)
m recoveryimage -j$(nproc --all)
buildsuccessful="${?}"
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))

export zip_path=$(ls "${outdir}"/*.zip | tail -n -1)
export zip_name=$(echo "${zip_path}" | sed "s|${outdir}/||")
if [ "${buildsuccessful}" == "0" ] && [ -e "${zip_path}" ]; then
    echo "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"

    echo "Uploading"

    github-release "${release_repo}" "${zip_name}" "${release_branch}" "${ROM} for ${device}

Date: $(env TZ="${timezone}" date)" "${outdir}/${zip_name}"

    echo "Uploaded"

    telegram -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

Download: ["${zip_name}"]("https://github.com/${release_repo}/releases/download/${zip_name}/${zip_name}")"
curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker

else
    echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    telegram -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
    exit 1
fi
