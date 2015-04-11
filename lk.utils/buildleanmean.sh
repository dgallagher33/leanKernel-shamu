#!/bin/bash

sdir="/home/android/kernel/leanKernel"
udir="/home/android/kernel/leanKernel/lk.utils"
outdir="/home/android/kernel/Out"
device="shamu"
cc="/home/android/kernel/arm-cortex_a15-linux-gnueabihf-linaro_4.9/bin/arm-eabi-"
filename="lk_${device}_lp-v${1}.zip"
ocuc_branch="lk-lp-ocuc"
mkbootimg="/bin/mkbootimg"

compile() {
  export CROSS_COMPILE=$cc
  export ARCH=arm
  export SUBARCH=arm
  export KBUILD_BUILD_USER=dwibbles33
  export KBUILD_BUILD_HOST=dwibbles33
  make clean && make mrproper
  make lk_defconfig
  make -j10
}

ramdisk() {
  cd $sdir/lk.ramdisk
  chmod 750 init* sbin/adbd* sbin/healthd
  chmod 644 default* uevent* res/images/charger/*
  chmod 755 sbin sbin/lkconfig
  chmod 700 sbin/lk-post-boot.sh
  chmod 755 res res/images res/images/charger
  chmod 640 fstab.shamu
  find . | cpio -o -H newc | gzip > /tmp/ramdisk.img
  $mkbootimg --kernel $sdir/arch/arm/boot/zImage-dtb  --ramdisk /tmp/ramdisk.img --cmdline "console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=shamu msm_rtb.filter=0x37 ehci-hcd.park=3 utags.blkdev=/dev/block/platform/msm_sdcc.1/by-name/utags utags.backup=/dev/block/platform/msm_sdcc.1/by-name/utagsBackup coherent_pool=8M" --pagesize 2048 -o $outdir/boot.img
}

zipit() {
  cd $udir
  cp -f $outdir/boot.img zip/
  cd zip
  zip -r $outdir/$1 *
  rm boot.img
  cd $sdir
} 


compile $1 && ramdisk && zipit $filename
[[ $1 =~ "ocuc" ]] && git checkout HEAD arch/arm/boot/dts/qcom/apq8084.dtsi
#compile $1 && ramdisk 
