#! /bin/bash

TARGET=$1
STOP=$2

if [ "$2" == "--stop" ]; then
  if [ "$1" == "--debug" ]; then
	sudo LD_LIBRARY_PATH=$PWD/build/output/debug $PWD/build/output/debug/crosvm stop $PWD/build/output/debug/crosvm.sock
  else
	sudo LD_LIBRARY_PATH=$PWD/build/output/release $PWD/build/output/release/crosvm stop $PWD/build/output/release/crosvm.sock
  fi
else
  if [ "$1" == "--debug" ]; then
    sudo LD_LIBRARY_PATH=$PWD/build/output/debug build/output/debug/crosvm run --disable-sandbox --rwdisk $PWD/build/output/rootfs.ext4 -s $PWD/build/output/debug/crosvm.sock -m 5019 -p "root=/dev/vda"  -p "intel_iommu=on" -p "drm.debug=255 debug loglevel=8 initcall_debug" --host_ip 10.0.0.1 --netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY  --wayland-dmabuf --x-display=$DISPLAY $PWD/build/output/vmlinux
  else
  sudo LD_LIBRARY_PATH=$PWD/build/output/release $PWD/build/output/release/crosvm run --disable-sandbox --rwdisk $PWD/build/output/rootfs.ext4 -s $PWD/build/output/release/crosvm.sock -m 5019 -p "root=/dev/vda" -p "intel_iommu=on" --host_ip 10.0.0.1 --netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY  --wayland-dmabuf --x-display=$DISPLAY $PWD/build/output/vmlinux

  fi
fi
