#! /bin/bash

# setup-build-directories.sh
# Make's sure all expected folder and mount points under /build
# exists

echo "Checking for all needed build directories.."
if [ ! -d "/build" ]
then
  echo "Creating /build directory."
  mkdir /build
else
  echo "/build exists."
fi

if [ ! -d "/build/patches" ]
then
  echo "Creating /build/patches directory."
  mkdir /build/patches
else
  echo "/build/patches exists."
fi

echo "Checking if /build/drm-intel exists.."
if [ ! -d "/build/drm-intel" ]
then
  echo "Creating /build/drm-intel directory."
  mkdir /build/drm-intel
else
  echo "/build/drm-intel exists."
fi
