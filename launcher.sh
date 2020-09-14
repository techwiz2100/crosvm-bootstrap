#! /bin/bash

TARGET=$(1:-"release"}
CHANNEL=$(2:"stable"}
STOP=${3:-"run"}

if [ "$2" == "--stop" ]; then
  if [ "$1" == "--debug" ]; then
    sudo LD_LIBRARY_PATH=$PWD/build/output/$CHANNEL/debug $PWD/build/output/$CHANNEL/crosvm stop $PWD/build/output/$CHANNEL/debug/crosvm.sock
  else
    sudo LD_LIBRARY_PATH=$PWD/build/output/$CHANNEL/release $PWD/build/output/$CHANNEL/crosvm stop $PWD/build/output/$CHANNEL/release/crosvm.sock
  fi
else
  if [ "$1" == "--debug" ]; then
    sudo LD_LIBRARY_PATH=$PWD/build/output/$CHANNEL/debug build/output/$CHANNEL/debug/crosvm run --disable-sandbox --rwdisk $PWD/build/output/rootfs.ext4 -s $PWD/build/output/$CHANNEL/debug/crosvm.sock -m 10240 --cpus 4 -p "root=/dev/vda"  -p "intel_iommu=on" -p "drm.debug=255 debug loglevel=8 initcall_debug" --host_ip 10.0.0.1 --netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl=true,glx=true,gles=true --x-display $DISPLAY --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY --wayland-dmabuf $PWD/build/output/vmlinux
  else
    sudo LD_LIBRARY_PATH=$PWD/build/output/$CHANNEL/release $PWD/build/output/$CHANNEL/release/crosvm run --disable-sandbox --rwdisk $PWD/build/output/rootfs.ext4 -s $PWD/build/output/$CHANNEL/release/crosvm.sock -m 10240 --cpus 4 -p "root=/dev/vda" -p "intel_iommu=on" --host_ip 10.0.0.1 --netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl=true,glx=true,gles=true --x-display=$DISPLAY --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY --wayland-dmabuf $PWD/build/output/vmlinux
  fi
fi
