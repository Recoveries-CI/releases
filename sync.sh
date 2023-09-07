#!/bin/bash

# Change to the Home Directory
cd ~

echo "Sync started for ${manifest_url}"
if [ "${jenkins}" == "true" ]; then
    telegram -M "Sync started for [OFOX](${manifest_url}): [See Progress](${BUILD_URL}console)"
else
    telegram -M "Sync started for [OFOX](${manifest_url})"
fi
SYNC_START=$(date +"%s")

# Clone the Sync Repo
git clone ${manifest_url}
cd sync

# Setup Branch names
if [ "$branch" = "fox_12.0" ]; then
	printf "Warning! Using fox_12.1 instead of fox_12.0.\n"
	branch="fox_12.1"
elif [ "$branch" = "fox_8.0" ]; then
	printf "Warning! Using fox_8.1 instead of fox_8.0.\n"
	branch="fox_8.1"
fi

# Setup the Sync Branch
if [ -z "$SYNC_BRANCH" ]; then
    export SYNC_BRANCH=$(echo ${branch} | cut -d_ -f2)
fi

if [ -d ${ROM_DIR}/bootable ]; then
# Update the Sources 
  echo "Updating OFox Sources"
  BOOTABLE=${ROM_DIR}/bootable/recovery;
  cd $ROM_DIR && repo sync --force-sync --fail-fast --no-tags --no-clone-bundle --optimized-fetch --prune -c -v;
  cd $BOOTABLE && git pull;
else
# Sync the Sources
  bash orangefox_sync.sh --branch $SYNC_BRANCH --path $ROM_DIR || { echo "ERROR: Failed to Sync OrangeFox Sources!" && exit 1; }
fi
# Change to the Source Directory
cd $ROM_DIR

# Clone the theme if not already present
if [ ! -d bootable/recovery/gui/theme ]; then
git clone https://gitlab.com/OrangeFox/misc/theme.git bootable/recovery/gui/theme || { echo "ERROR: Failed to Clone the OrangeFox Theme!" && exit 1; }
fi

# Clone the Commonsys repo, only for fox_9.0
if [ "$branch" = "fox_9.0" ]; then
git clone --depth=1 https://github.com/TeamWin/android_vendor_qcom_opensource_commonsys.git -b android-9.0 vendor/qcom/opensource/commonsys || { echo "WARNING: Failed to Clone the Commonsys Repo!"; }
fi

# Clone Trees
git clone $DT_LINK $DT_PATH || { echo "ERROR: Failed to Clone the Device Trees!" && exit 1; }

# Clone Additional Dependencies (Specified by the user)
for dep in "${DEPS[@]}"; do
	rm -rf $(echo $dep | sed 's/ -b / /g')
	git clone --depth=1 --single-branch $dep
done

# Cherry-pick gerrit patches
#if [ "$branch" = "fox_12.1" ]; then
#  git -C bootable/recovery fetch https://gitlab.com/faoliveira78/Recovery
#  git -C bootable/recovery cherry-pick 9b519521ef7ff88eec66f6223dd43f59c8ab49f7
#  git -C bootable/recovery cherry-pick 167d8000fd4e83e94a4cfbb5f25937b0e024f5ee
#  git -C bootable/recovery cherry-pick fc51f2797df56bcdc247e80cb4bae36ac87a31d0
#fi

# Magisk
if [[ $OF_USE_LATEST_MAGISK = "true" || $OF_USE_LATEST_MAGISK = "1" ]]; then
	echo "Downloading the Latest Release of Magisk..."
	LATEST_MAGISK_URL="$(curl -sL https://api.github.com/repos/topjohnwu/Magisk/releases/latest | jq -r . | grep browser_download_url | grep Magisk | cut -d : -f 2,3 | sed 's/"//g')"
	mkdir -p $HOME/Magisk
	cd $HOME/Magisk
	aria2c $LATEST_MAGISK_URL 2>&1 || wget $LATEST_MAGISK_URL 2>&1
	echo "Magisk Downloaded Successfully"
	echo "Renaming .apk to .zip ..."
	#rename 's/.apk/.zip/' Magisk*
	mv $("ls" Magisk*.apk) $("ls" Magisk*.apk | sed 's/.apk/.zip/g')
	cd $ROM_DIR >/dev/null
	echo "Done!"
fi
syncsuccessful="${?}"
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
