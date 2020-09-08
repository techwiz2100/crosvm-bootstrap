#! /bin/bash

# deploy-depends-and-configure.sh USERNAME PASSWORD
# Install support packages and configure system with specified user and password
# User will be added to the sudo, wheel, video, and audio user groups
# Root password will also match specified user's password

USER=$1
PASS=$2

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

echo "root:$PASS" | chpasswd
useradd -m -s /bin/bash -G sudo,audio,video,input,render,lp $USER
echo "$USER:$PASS" | chpasswd

export RUST_VERSION=1.45.2
export CARGO_HOME=/usr/local/cargo
export PATH=/usr/local/cargo/bin:$PATH
export RUSTFLAGS='--cfg hermetic'

mkdir /build
cd /build

curl -LO "https://static.rust-lang.org/rustup/archive/1.22.1/x86_64-unknown-linux-gnu/rustup-init" && echo "49c96f3f74be82f4752b8bffcf81961dea5e6e94ce1ccba94435f12e871c3bdb *rustup-init" | sha256sum -c -
chmod +x rustup-init
./rustup-init -y --no-modify-path --default-toolchain $RUST_VERSION
rm rustup-init
chmod -R a+w $RUSTUP_HOME $CARGO_HOME
rustup --version
cargo --version
rustc --version
rustup default stable

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=/build/depot_tools:$PATH
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

// Repo initialization and cloning all needed Libraries.
ln -s /usr/bin/python3 /usr/bin/python

repo init -u  https://github.com/kalyankondapally/manifest.git -m default.xml
repo sync

exit


