#!/usr/bin/env bash

set -e -x

# Clone toolchain
if [ ! -d clang ]; then mkdir clang && curl -Lsq "${CLANG_TAR_URL}" -o clang.tgz && tar -xzf clang.tgz -C clang; fi
[ ! -d binutils ] && git clone --depth=1 "${BINUTILS_GIT}" -b android12L-release binutils
[ ! -d binutils-32 ] && git clone --depth=1 "${BINUTILS_32_GIT}" -b android12L-release binutils-32
[ ! -d build_tools ] && git clone --depth=1 "${BUILD_TOOLS}" -b android13-s3-release build_tools

# Clone kernel source
[ ! -d kernel-msm ] && git clone --depth=1 "${KERNEL_SOURCE_URL}" -b 4.14.314/msm8998_oneplus kernel-msm

# Set toolchain path
PATH="${WORK}/clang/bin:${WORK}/binutils/bin:${WORK}/binutils-32/bin:${WORK}/build_tools/linux-x86/bin:/bin:$PATH"

# Build kernel
cd "${KERNEL_SRC}" || exit 1
rm -rf out
make mrproper

# Android cross compile make function
make_fun() {
	make O=out ARCH=arm64 \
		CC=clang HOSTCC=clang \
		CLANG_TRIPLE=aarch64-linux-gnu- \
		CROSS_COMPILE=aarch64-linux-android- \
		CROSS_COMPILE_ARM32=arm-linux-androideabi- \
		LLVM=1 \
		LLVM_IAS=1 "$@"
}

# Make defconfig
make_fun msm8998_defconfig

# Make kernel
make_fun -j"$(nproc --all)" || make_fun -j1

# Upload built kernel
cd ${WORK}
[ ! -d ANY ] && git clone --depth=1 "${ANYKERNEL_GIT}" ANY
cd ANY || exit 1
rm -rf *Image* *.zip
cp "${KERNEL_SRC}/out/arch/arm64/boot/Image.gz-dtb" ./
dates=$(date "+%Y%m%d%I%M%S")
# Upload to oshi.at
if [ -z "$TIMEOUT" ];then
    TIMEOUT=20160
fi
zip -r9 "${dates}.zip" * -x .git README.md *placeholder
curl -T "${dates}.zip" https://oshi.at/${dates}.zip/${TIMEOUT} ; curl -T "Image.gz-dtb" https://oshi.at/Image.gz-dtb/${TIMEOUT}
curl -F document=@"$(echo *.gz-dtb)" https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument?chat_id=${TELEGRAM_CHAT} >& /dev/null 2>&1
curl -F document=@"$(echo *.zip)" https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument?chat_id=${TELEGRAM_CHAT} >& /dev/null 2>&1
