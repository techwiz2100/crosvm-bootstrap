#! /bin/bash

# build-rootfs-builder-container.sh
# Set up build environment for docker container that generates Debian rootfs
# then calls docker build.

if [ -e "build" ]; then
    rm -rf build
fi
mkdir -p build/{scripts,config}

cp scripts/run-rootfs-builder.sh build/run.sh
cp scripts/create-image.py build/scripts/
cp scripts/deploy-depends-and-configure.sh build/scripts/deploy.sh
cp dockerfiles/rootfs-builder.dockerfile build/Dockerfile
cp -r default-config/* build/config/
cd build/

SHA=`git rev-parse --short HEAD 2>/dev/null`
TAG=`git describe 2>/dev/null`
if [ -z $? ]; then
    echo "$TAG" > VERSION
else
    echo "COMMIT-$SHA" > VERSION
fi

docker build -t rootfs-builder:latest .