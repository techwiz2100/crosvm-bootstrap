#! /bin/bash

./scripts/apply_patches.sh
./scripts/build-rootfs-builder-container.sh
docker run -it --privileged -v $PWD/build/output:/app/output -v $PWD/../drm-intel:/app/drm-intel -v $PWD/../cros_vm:/app/cros_vm rootfs-builder:latest
