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

echo "Checking if /build/cros_vm exists.."
if [ ! -d "/build/cros_vm" ]
then
  echo "Creating /build/cros_vm directory."
  mkdir /build/cros_vm
else
  echo "/build/cros_vm exists."
fi

echo "Checking if /build/drm-intel exists.."
if [ ! -d "/build/drm-intel" ]
then
  echo "Creating /build/drm-intel directory."
  mkdir /build/drm-intel
else
  echo "/build/drm-intel exists."
fi

echo "Checking if /build/patches exists.."
if [ ! -d "/build/patches" ]
then
  echo "Creating /build/patches directory."
  mkdir /build/patches
else
  echo "/build/patches exists."
fi
