#!/bin/bash
echo "Sync started for ${manifest_url}/tree/${branch}"
if [ "${jenkins}" == "true" ]; then
    telegram -M "Sync started for [PBRP](${manifest_url}/tree/${branch}): [See Progress](${BUILD_URL}console)"
else
    telegram -M "Sync started for [PBRP](${manifest_url}/tree/${branch})"
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
#if [ "$branch" = "android-12.1" ]; then
#  git -C bootable/recovery fetch https://github.com/faoliveira78/android_bootable_recovery-pbrp
#  git -C bootable/recovery cherry-pick aeffba7f67e8742d169f0c077d6ace8891ec7374
#  git -C bootable/recovery cherry-pick d6d06d80740e60dd692d148e2cadfea3ef6cb698
#fi

if [[ -v pb_version ]]; then
  sed -i "s/#define PB_MAIN_VERSION.*/#define PB_MAIN_VERSION     \"$pb_version\"/" bootable/recovery/variables.h
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
