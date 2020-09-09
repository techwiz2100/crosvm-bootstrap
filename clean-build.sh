#! /bin/bash

./scripts/apply_patches.sh
sudo ./scripts/build-rootfs-builder-container.sh
sudo docker run -it --privileged -v $PWD/build/output:/app/output -v $PWD/../drm-intel:/app/drm-intel -v $PWD/../cros_vm:/app/cros_vm rootfs-builder:latest
