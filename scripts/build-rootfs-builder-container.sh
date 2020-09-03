#! /bin/bash

if [ -e "build" ]; then
    rm -rf build
fi
mkdir -p build/scripts

cp scripts/run-rootfs-builder.sh build/run.sh
cp scripts/create-image.py build/scripts/
cp dockerfiles/rootfs-builder.dockerfile build/Dockerfile
cp -r default-config/ build/
git clone https://github.com/kalyankondapally/debian-rootfs build/debian-rootfs
cd build/

SHA=`git rev-parse --short HEAD 2>/dev/null`
TAG=`git describe 2>/dev/null`
if [ -z $? ]; then
    echo "$TAG" > VERSION
else
    echo "COMMIT-$SHA" > VERSION
fi

#docker build .