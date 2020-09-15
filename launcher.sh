#! /bin/bash

XDG_RUNTIME_DIR=$1
WAYLAND_DISPLAY=$2
X_DISPLAY=$3
TARGET=${4:-"--release"}
CHANNEL=${5:-"--stable"}
STOP=${6:-"--run"}
LOCAL_CURRENT_CHANNEL=stable
LOCAL_BUILD_TARGET=release
KERNEL_CMD_OPTIONS=""

if [ $CHANNEL == "--stable" ]; then
  LOCAL_CURRENT_CHANNEL=stable
else
  LOCAL_CURRENT_CHANNEL=master
fi

if [ $TARGET == "--release" ]; then
  LOCAL_BUILD_TARGET=release
else
  LOCAL_BUILD_TARGET=debug
  KERNEL_CMD_OPTIONS="drm.debug=255 debug loglevel=8 initcall_debug"
fi
LINKER_PATH=$PWD/build/output/$LOCAL_CURRENT_CHANNEL/$LOCAL_BUILD_TARGET
export CURRENT_CHANNEL=$LOCAL_CURRENT_CHANNEL

if [ $STOP == "--stop" ]; then
  sudo LD_LIBRARY_PATH=$LINKER_PATH $PWD/build/output/$LOCAL_CURRENT_CHANNEL/$LOCAL_BUILD_TARGET/crosvm stop $PWD/build/output/$LOCAL_CURRENT_CHANNEL/$LOCAL_BUILD_TARGET/crosvm.sock
else
    sudo LD_LIBRARY_PATH=$LINKER_PATH --preserve-env=$CURRENT_CHANNEL $PWD/build/output/$LOCAL_CURRENT_CHANNEL/debug/crosvm run --disable-sandbox --rwdisk $PWD/build/output/rootfs.ext4 -s $PWD/build/output/$LOCAL_CURRENT_CHANNEL/debug/crosvm.sock -m 10240 --cpus 4 -p "root=/dev/vda"  -p "intel_iommu=on" -p $KERNEL_CMD_OPTIONS --host_ip 10.0.0.1 --netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl=true,glx=true,gles=true --x-display $DISPLAY --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY --wayland-dmabuf $PWD/build/output/$LOCAL_CURRENT_CHANNEL/vmlinux
fi
