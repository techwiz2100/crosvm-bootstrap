#! /bin/bash

sudo LD_LIBRARY_PATH=$WLD/lib/x86_64-linux-gnu XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR DISPLAY=$DISPLAY build/output/crosvm run --disable-sandbox --rwdisk build/output/rootfs.ext4 -s crosvm.sock -m 5019  -p "root=/dev/vda" -p "intel_iommu=on" -p "drm.debug=255 debug loglevel=8 initcall_debug"  --host_ip 10.0.0.1 --netmask 255.255.255.0 --mac 9C:B6:D0:E3:96:4D --gpu egl --wayland-sock=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY  --wayland-dmabuf --x-display=$DISPLAY build/output/vmlinux
