#! /bin/bash

XDG_RUNTIME_DIR=$1
WAYLAND_DISPLAY=$2
X_DISPLAY=$3
TARGET=${4:-"release"}
CHANNEL=${5:-"stable"}
STOP=${6:-"run"}

if [ $CHANNEL == "--stable" ]; then
  CURRENT_CHANNEL=stable
else
  CURRENT_CHANNEL=master
fi

export CHANNEL=$CURRENT_CHANNEL
echo $CURRENT_CHANNEL

sudo LD_LIBRARY_PATH=$PWD/build/output/release $PWD/build/output/release/crosvm stop $PWD/build/output/release/crosvm.sock

if [ $STOP == "--stop" ]; then
  if [ $TARGET == "--debug" ]; then
    sudo LD_LIBRARY_PATH=$PWD/build/output/$CURRENT_CHANNEL/debug $PWD/build/output/$CURRENT_CHANNEL/crosvm stop $PWD/build/output/$CURRENT_CHANNEL/debug/crosvm.sock
  else
    sudo LD_LIBRARY_PATH=$PWD/build/output/$CURRENT_CHANNEL/release $PWD/build/output/$CURRENT_CHANNEL/crosvm stop $PWD/build/output/$CURRENT_CHANNEL/release/crosvm.sock
  fi
else
  if [ $TARGET == "--debug" ]; then
    sudo LD_LIBRARY_PATH=$PWD/build/output/$CURRENT_CHANNEL/debug $PWD/build/output/$CURRENT_CHANNEL/debug/crosvm run --disable-sandbox --rwdisk $PWD/build/output/rootfs.ext4 -s $PWD/build/output/$CURRENT_CHANNEL/debug/crosvm.sock -m 10240 --cpus 4 -p "root=/dev/vda"  -p "intel_iommu=on" -p "drm.debug=255 debug loglevel=8 initcall_debug" --host_ip 10.0.0.1 --netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl=true,glx=true,gles=true --x-display $DISPLAY --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY --wayland-dmabuf $PWD/build/output/vmlinux
  else
    sudo LD_LIBRARY_PATH=$PWD/build/output/$CURRENT_CHANNEL/release --preserve-env=$CURRENT_CHANNEL $PWD/build/output/$CURRENT_CHANNEL/release/crosvm run --disable-sandbox --rwdisk $PWD/build/output/rootfs.ext4 -s $PWD/build/output/$CURRENT_CHANNEL/release/crosvm.sock -m 10240 --cpus 4 -p "root=/dev/vda" -p "intel_iommu=on" --host_ip 10.0.0.1 --netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl=true,glx=true,gles=true --x-display=$DISPLAY --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY --wayland-dmabuf $PWD/build/output/vmlinux
  fi
fi
