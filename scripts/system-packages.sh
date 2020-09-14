#! /bin/bash

# system-packages.sh
# Install support packages and configure system.

dpkg --add-architecture i386
dpkg --configure -a
apt update
apt upgrade

echo "Checking if 32 bit and 64 bit architecture is supported ..."

if [ "x$(dpkg --print-foreign-architectures)" != "xi386" ]; then
  echo "Failed to add 32 bit architecture."
  exit 2
fi

echo "Installing needed system packages..."
apt install -y --no-remove sudo ssh git meson gcc g++ gcc-i686-linux-gnu g++-i686-linux-gnu libxvmc-dev
apt install -y --no-remove autoconf nasm make python3-mako llvm xutils-dev libtool automake libc6-dev
apt install -y --no-remove cmake pkg-config libatomic-ops-dev python3-setuptools python3-certifi gpgv2
apt install -y --no-remove libffi-dev libxml2-dev bison flex zlib1g-dev libcap-dev cargo
apt install -y --no-remove libfdt-dev gcc-multilib g++-multilib curl dh-autoreconf
apt install -y --no-remove libpixman-1-0 libpixman-1-dev libsensors-dev
apt install -y --no-remove libxcb1-dev libxcb-composite0 libxcb-composite0-dev libxcb-dri3-dev
apt install -y --no-remove libxkbcommon0 libxkbcommon-dev libxxf86vm-dev
apt install -y --no-remove build-essential libssl-dev libelf-dev bc texlive-font-utils
apt install -y --no-remove libexpat1-dev libinput-dev xwayland mesa-utils-extra
apt install -y --no-remove libc6-dev-x32-i386-cross libzstd-dev libx11-xcb-dev
apt install -y --no-remove libunwind-dev libxcb-dri2-0-dev python3-distutils libxshmfence-dev
apt install -y --no-remove libxrandr-dev libxdamage-dev gettext valgrind libxcb-glx0-dev
apt install -y --no-remove libxcb-shm0-dev libxkbfile-dev xterm libxcb-present-dev libfdt1
apt install -y --no-remove glslang-tools libxshmfence-dev libvulkan-dev libvulkan1 libselinux1-dev libselinux1 dpkg-dev

echo "Installing needed i386 system packages..."
apt install -y --no-remove libunwind-dev:i386 libsensors-dev:i386 libexpat1-dev:i386 zlib1g-dev:i386 libelf-dev:i386
apt install -y --no-remove libxdamage-dev:i386 libxcb-glx0-dev:i386 libx11-xcb-dev:i386
apt install -y --no-remove libxcb-dri2-0-dev:i386 libxcb-dri3-dev:i386 libxcb-present-dev:i386 libxshmfence-dev:i386
apt install -y --no-remove libxxf86vm-dev:i386 libxrandr-dev:i386 libvulkan1:i386
apt install -y --no-remove libvulkan-dev:i386 libselinux1:i386 libselinux1-dev:i386 libxcb-shm0:i386 libxcb-shm0-dev:i386
apt install -y --no-remove libxml2-dev:i386 automake:i386 libc6-dev:i386 libffi-dev:i386

# Make sure we have libc packages correctly installed
if [ "$(dpkg -s linux-libc-dev:amd64 | grep ^Version:)" !=  "$(dpkg -s linux-libc-dev:i386 | grep ^Version:)" ]; then
  echo "linux-libc-dev:amd64 and linux-libc-dev:i386 do have different versions!"
  echo "Please fix this after rootfs is generated."
fi
if [ "$(dpkg -s libc6-dev:amd64 | grep ^Version:)" !=  "$(dpkg -s libc6-dev:i386 | grep ^Version:)" ]; then
  echo "libc6-dev:amd64 and libc6-dev:i386 do have different versions!"
  echo "Please fix this after rootfs is generated."
fi

