#! /bin/bash

./scripts/build-rootfs-builder-container.sh
docker run -it --privileged -v $PWD/build/output:/app/output rootfs-builder:latest
