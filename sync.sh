#!/bin/bash
echo "Sync started for ${manifest_url}/tree/${branch}"
if [ "${jenkins}" == "true" ]; then
    telegram -M "Sync started for [TWRP](${manifest_url}/tree/${branch}): [See Progress](${BUILD_URL}console)"
else
    telegram -M "Sync started for [TWRP](${manifest_url}/tree/${branch})"
fi
SYNC_START=$(date +"%s")
rm -rf .repo/local_manifests
mkdir -p .repo/local_manifests
wget "${local_manifest_url}" -O .repo/local_manifests/manifest.xml
repo init -u "${manifest_url}" -b "${branch}" --depth 1
cores=$(nproc --all)
if [ "${cores}" -gt "8" ]; then
    cores=8
fi
repo forall -c 'git reset --hard ; git clean -fdx'
repo sync --force-sync --fail-fast --no-tags --no-clone-bundle --optimized-fetch --prune "-j${cores}" -c -v
syncsuccessful="${?}"

# Cherry-pick gerrit patches
if [ "$branch" = "twrp-12.1" ]; then
#  if [[ "$local_manifest_url" == *"cheesedump"* ]]; then
#    git -C device/oneplus/cheeseburger_dumpling fetch https://gerrit.twrp.me/android_device_oneplus_cheeseburger_dumpling refs/changes/72/6872/1 && git -C device/oneplus/cheeseburger_dumpling cherry-pick FETCH_HEAD 
#  elif [[ "$local_manifest_url" == *"op5_t"* ]]; then
#    source build/envsetup.sh
#    repopick 5683
#    repopick -t op5_t_0511 -P device/oneplus/cheeseburger_dumpling
#  fi
fi

SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ "${syncsuccessful}" == "0" ]; then
    echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    source "${my_dir}/build.sh"
else
    echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    telegram -N -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    curl --data parse_mode=HTML --data chat_id=$TELEGRAM_CHAT --data sticker=CAADBQADGgEAAixuhBPbSa3YLUZ8DBYE --request POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker
    exit 1
fi
