#! /bin/bash

# system-packages.sh
# Install support packages and configure system.

dpkg --configure -a
apt update
apt upgrade
apt-get install -y lxc lxctl lxc-templates sudo ssh git meson gcc g++
apt-get install -y autoconf nasm make python3-mako llvm xutils-dev libtool
apt-get install -y cmake pkg-config libatomic-ops-dev python3-setuptools
apt-get install -y libffi-dev libxml2-dev bison flex zlib1g-dev libcap-dev
apt-get install -y libfdt-dev gcc-multilib g++-multilib curl
apt-get install -y libpixman-1-0 libpixman-1-dev
apt-get install -y libxcb1-dev libxcb-composite0 libxcb-composite0-dev
apt-get install -y libxkbcommon0 libxkbcommon-dev
apt-get install -y build-essential libssl-dev libelf-dev bc texlive-font-utils
apt-get install -y libexpat1-dev libinput-dev xwayland mesa-utils-extra
apt-get install -y libc6-dev-x32-i386-cross libzstd-dev libx11-xcb-dev
apt-get install -y libunwind-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-present-dev
apt-get install -y libxshmfence-dev libxrandr-dev libxdamage-dev libxcb-glx0-dev
apt-get install -y libxcb-shm0-dev libxxf86vm-dev libxkbfile-dev xterm

