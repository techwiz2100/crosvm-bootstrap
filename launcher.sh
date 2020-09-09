#! /bin/bash

STOP=$1

if [ $1 != "--stop" ]; then
  if [ $1 == "--debug" ]; then
	sudo build/output/debug/crosvm run --disable-sandbox --rwdisk build/output/rootfs.ext4 -s build/output/crosvm.sock -m 5019  -p "root=/dev/vda" -p "intel_iommu=on"
	-p "drm.debug=255 debug loglevel=8 initcall_debug"  --host_ip 10.0.0.1 --netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY
	--wayland-dmabuf --x-display=$DISPLAY build/output/vmlinux
  else
	sudo build/output/release/crosvm run --disable-sandbox --rwdisk build/output/rootfs.ext4 -s build/output/crosvm.sock -m 5019  -p "root=/dev/vda" -p "intel_iommu=on" --host_ip 10.0.0.1
	--netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY  --wayland-dmabuf --x-display=$DISPLAY
	build/output/vmlinux
  fi
else
  if [ $1 == "--debug" ]; then
	sudo build/output/debug/crosvm stop build/output/crosvm.sock
  else
	sudo build/output/release/crosvm stop build/output/crosvm.sock
fi
