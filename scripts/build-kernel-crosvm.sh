#! /bin/bash

# build-kernel-crosvm.sh
# Builds cros_vm and kernel

export RUST_VERSION=1.45.2
export CARGO_HOME=/usr/local/cargo
export PATH=/usr/local/cargo/bin:$PATH
export RUSTFLAGS='--cfg hermetic'

# Build x86 config
if [ -d "/build/drm-intel/arch/x86/configs" ]
then
  echo "Found drm-intel folder. Building kernel..."
  cd /build/drm-intel
  make clean
  make x86_64_defconfig
  make
else
  echo "Unable to find drm-intel folder.Kernel is not built."
fi
