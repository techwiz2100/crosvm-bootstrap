#! /bin/bash

# package-builder.sh
# Builds all needed drivers, cros_vm and other needed packages.

# exit on any script line that fails
set -o errexit
# bail on any unitialized variable reads
set -o nounset
# bail on failing commands before last pipe
set -o pipefail

BUILD_TYPE=${1:-"release"}
CLEAN_BUILD=${2:-"incremental"}
CURRENT_CHANNEL=${3:-"stable"}
UPDATE_CHANNEL=${4:-"false"}
BUILD_RUST=${5:-"false"}
BUILD_KERNEL=${6:-"false"}
LOCAL_BUILD_TYPE=release
LOCAL_CHANNEL=stable
LOCAL_UPDATE_CHANNEL=0

if [ $UPDATE_CHANNEL == "--true" ]; then
LOCAL_UPDATE_CHANNEL=1
fi

if [ $CURRENT_CHANNEL == "--master" ]; then
LOCAL_CHANNEL=master
  if [ $BUILD_TYPE == "--debug" ]; then
    export RUSTFLAGS='--cfg hermetic -L /opt/master/debug/x86_64/lib/x86_64-linux-gnu/ -L /opt/master/debug/x86_64/lib/ -L /usr/lib/x86_64-linux-gnu/'
  else
    export RUSTFLAGS='--cfg hermetic -L /opt/master/release/x86_64/lib/x86_64-linux-gnu/ -L /opt/master/release/x86_64/lib/ -L /usr/lib/x86_64-linux-gnu/'
  fi
else
  if [ $BUILD_TYPE == "--debug" ]; then
    export RUSTFLAGS='--cfg hermetic -L /opt/stable/debug/x86_64/lib/x86_64-linux-gnu/ -L /opt/stable/debug/x86_64/lib/ -L /usr/lib/x86_64-linux-gnu/'
  else
    export RUSTFLAGS='--cfg hermetic -L /opt/stable/release/x86_64/lib/x86_64-linux-gnu/ -L /opt/stable/release/x86_64/lib/ -L /usr/lib/x86_64-linux-gnu/'
  fi
fi

# Set Working Build directory based on the channel.
WORKING_DIR=/build/$LOCAL_CHANNEL

if [ $BUILD_TYPE == "--debug" ]; then
LOCAL_BUILD_TYPE=debug
fi

# Set Lib Directory based on the channel.
BASE_DIR=/opt/$LOCAL_CHANNEL/$LOCAL_BUILD_TYPE
CROSS_SETTINGS=/build/meson-cross-i686-$LOCAL_CHANNEL-$LOCAL_BUILD_TYPE.ini

# Export environment variables
export WLD64=$BASE_DIR/x86_64
export RUST_VERSION=1.45.2
export CARGO_HOME=/usr/local/cargo
export PATH=$CARGO_HOME:$PATH
export C_INCLUDE_PATH=$WLD64/include:$WLD64/include/libdrm/
export CPLUS_INCLUDE_PATH=$WLD64/include:$WLD64/include/libdrm/
export CPATH=$WLD64/include:$WLD64/include/libdrm/
export PATH="$PATH:$WLD64/include/:$WLD64/include/libdrm/:$WLD64/bin"
export WLD32=$BASE_DIR/x86
#ldconfig -v 2>/dev/null | grep -v ^$'\t'

# x86_64 specifi build settings
export ACLOCAL_PATH=$WLD64/share/aclocal
export ACLOCAL="aclocal -I $ACLOCAL_PATH"
export PKG_CONFIG_PATH=$WLD64/lib/x86_64-linux-gnu/pkgconfig:$WLD64/share/pkgconfig/:$WLD64/lib/pkgconfig
export WAYLAND_PROTOCOLS_PATH=$WLD64/share/wayland-protocols
LOCAL_MESON_BUILD_DIR=build.$LOCAL_BUILD_TYPE.x86_64

# Remove all existing pre-built libraries.
if [[ ($CLEAN_BUILD == "--clean" && -d $BASE_DIR) ]]; then
  rm -rf $BASE_DIR
fi

cd /build

if [ $BUILD_RUST == "--true" ]; then
curl -LO "https://static.rust-lang.org/rustup/archive/1.22.1/x86_64-unknown-linux-gnu/rustup-init" && echo "49c96f3f74be82f4752b8bffcf81961dea5e6e94ce1ccba94435f12e871c3bdb *rustup-init" | sha256sum -c -
chmod +x rustup-init
./rustup-init -y --no-modify-path --default-toolchain $RUST_VERSION
rm rustup-init
chmod -R a+w $RUSTUP_HOME $CARGO_HOME
rustup --version
cargo --version
rustc --version
rustup default stable
fi

# Repo initialization and cloning all needed Libraries.
if [ ! -f "/usr/bin/python" ]; then
ln -s /usr/bin/python3 /usr/bin/python
fi

if [ ! -d "/build/depot_tools" ]; then
  echo "Cloning Depot Tools."
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  git config --global color.ui false
else
  echo "Updating Depot Tools."
  cd /build/depot_tools/
  git pull
fi

export PATH=/build/depot_tools:$PATH
echo "Working Directory:" $WORKING_DIR

# Ensure we have repo for all channels
if [ ! -d "/build/stable" ]; then
  mkdir /build/stable
  cd /build/stable
  repo init -u  https://github.com/kalyankondapally/manifest.git -m default.xml
  LOCAL_UPDATE_CHANNEL=1;
fi

if [ ! -d "/build/master" ]; then
  mkdir /build/master
  cd /build/master
  repo init -u  https://github.com/kalyankondapally/manifest.git -m master.xml
  LOCAL_UPDATE_CHANNEL=1;
fi

if [ $LOCAL_UPDATE_CHANNEL == 1 ]; then
  cd $WORKING_DIR
  echo "Fetching latest sources for" $LOCAL_CHANNEL "Channel"
  repo sync
  echo $LOCAL_CHANNEL "Updated"
fi

# Print all environment settings
echo "Build settings used for 64bit builds....."
if [ $BUILD_TYPE == "--release" ]; then
  echo "Build Type: Release"
else
  echo "Build Type: Debug"
fi
if [ $BUILD_RUST == "--true" ]; then
  echo "Building Rust: True"
else
  echo "Building Rust: False"
fi
echo "Channel:" $LOCAL_CHANNEL
echo "Build Dir:" $LOCAL_MESON_BUILD_DIR
if [ $CLEAN_BUILD == "--clean" ]; then
  echo "Clean" $LOCAL_BUILD_TYPE "Build"
else
  echo "Incremental" $LOCAL_BUILD_TYPE "Build"
fi
echo "---------------------------------"

# print gcc environment
echo "C environment settings"
gcc -xc -E -v
echo "---------------------------------"
echo "C++ environment settings"
gcc -xc++ -E -v
echo "---------------------------------"

env
echo "---------------------------------"


# Create settings for cross compiling
if [ $CLEAN_BUILD == "--clean" ]; then
  if [ -f $CROSS_SETTINGS ]; then
    rm $CROSS_SETTINGS
  fi
fi

function makeclean_asneeded() {
if [ $CLEAN_BUILD == "--clean" ]; then
  make clean
fi
}

function mesonclean_asneeded() {
if [[ ($CLEAN_BUILD == "--clean" && -d $LOCAL_MESON_BUILD_DIR) ]]; then
  rm -rf $LOCAL_MESON_BUILD_DIR
fi
}

function ensure_aclocal_dir_x86_64() {
echo "checking " $WLD64/share/aclocal
if [ ! -d "$WLD64/share/aclocal" ]; then
  if [ ! -d /opt/$LOCAL_CHANNEL ]; then
    mkdir /opt/$LOCAL_CHANNEL
  fi

  if [ ! -d $BASE_DIR ]; then
    mkdir $BASE_DIR
  fi
  if [ ! -d $WLD64 ]; then
    mkdir $WLD64
  fi

  if [ ! -d "$WLD64/share" ]; then
    mkdir $WLD64/share
  fi

  mkdir $WLD64/share/aclocal
  if [ ! -d "$WLD64/share/aclocal" ]; then
    echo "Failed to create" $WLD64/share/aclocal
  fi
else
  echo $WLD64/share/aclocal "exists"
fi
}

# 64 bit build
echo "Building 64bit libraries............"
ensure_aclocal_dir_x86_64

# Build libpciaccess.
cd $WORKING_DIR/xorg-libpciaccess
echo "Building 64bit libpciaccess............"
#makeclean_asneeded
make clean

./autogen.sh --prefix=$WLD64
make install
cd $WORKING_DIR/mesa-drm

# Build drm
echo "Building 64bit drm............"
mesonclean_asneeded

meson setup $LOCAL_MESON_BUILD_DIR -Dprefix=$WLD64  -Dintel=true -Dradeon=false -Damdgpu=false -Dnouveau=false -Domap=false -Dexynos=false -Dfreedreno=false -Dtegra=false -Dvc4=false -Detnaviv=false --buildtype $LOCAL_BUILD_TYPE && ninja -C $LOCAL_MESON_BUILD_DIR install
cd $WORKING_DIR/wayland


# Build wayland
#makeclean_asneeded
echo "Building 64bit wayland............"
make clean

./autogen.sh --disable-documentation --prefix=$WLD64
make install
cd $WORKING_DIR/wayland-protocols

# Build wayland-protocols
echo "Building wayland-protocols............"
#makeclean_asneeded
make clean
./autogen.sh --prefix=$WLD64
make install
cd $WORKING_DIR/xorgproto

# Build xorgproto
echo "Building xorgproto............"
mesonclean_asneeded
meson setup $LOCAL_MESON_BUILD_DIR -Dprefix=$WLD64 && ninja -C $LOCAL_MESON_BUILD_DIR install
cd $WORKING_DIR/mesa

# Build mesa
echo "Building 64bit Mesa............"
mesonclean_asneeded

meson setup $LOCAL_MESON_BUILD_DIR --buildtype $LOCAL_BUILD_TYPE -Dprefix=$WLD64 -Ddri3="enabled" -Dshader-cache="enabled" -Dtools="glsl,nir" -Dplatforms="x11,wayland" -Ddri-drivers="" -Dgallium-drivers="iris,virgl,swrast" -Dvulkan-drivers="intel" -Dgallium-vdpau="disabled" -Dgallium-va="disabled" -Dopengl="true" -Dglx="dri" -Dselinux="true" -Dgles1="enabled" -Dgles2="enabled" -Dglx-direct="true" -Degl="enabled" -Dllvm="disabled" && ninja -C $LOCAL_MESON_BUILD_DIR install
cd $WORKING_DIR/libepoxy

# Build libepoxy
echo "Building 64bit libepoxy............"
mesonclean_asneeded

meson setup $LOCAL_MESON_BUILD_DIR  --buildtype $LOCAL_BUILD_TYPE -Dprefix=$WLD64 && ninja -C $LOCAL_MESON_BUILD_DIR install
cd $WORKING_DIR/minigbm

# Build minigbm
echo "Building 64bit Minigbm............"
#makeclean_asneeded
make clean
make CPPFLAGS="-DDRV_I915" DRV_I915=1 install DESTDIR=$WLD64 LIBDIR=lib/x86_64-linux-gnu
cd $WORKING_DIR/virglrenderer

# Build virglrenderer
echo "Building 64 bit VirglRenderer............"
mesonclean_asneeded

meson setup $LOCAL_MESON_BUILD_DIR -Dplatforms=auto -Dminigbm_allocation=true  --buildtype $LOCAL_BUILD_TYPE -Dprefix=$WLD64 && ninja -C $LOCAL_MESON_BUILD_DIR install

echo "Building 64 bit CrosVM............"
cd $WORKING_DIR/cros_vm/src/platform/crosvm
cargo clean --target-dir $LOCAL_MESON_BUILD_DIR
rm -rf $LOCAL_MESON_BUILD_DIR
if [[ ($CLEAN_BUILD == "--clean" && -d $LOCAL_MESON_BUILD_DIR) ]]; then
  cargo clean --target-dir $LOCAL_MESON_BUILD_DIR
  rm -rf $LOCAL_MESON_BUILD_DIR
fi
if [ $BUILD_TYPE == "--debug" ]; then
  cargo build --target-dir $LOCAL_MESON_BUILD_DIR --features 'default-no-sandbox wl-dmabuf gpu x'
else
  cargo build --target-dir $LOCAL_MESON_BUILD_DIR --release --features 'default-no-sandbox wl-dmabuf gpu x'
fi

if [ -f $LOCAL_MESON_BUILD_DIR/$LOCAL_BUILD_TYPE/crosvm ]; then
  if [ -e /build/output ]; then
    echo "Copying CrosVM to Output Directory:" build/output/$LOCAL_CHANNEL/$LOCAL_BUILD_TYPE/ 
    mv $LOCAL_MESON_BUILD_DIR/$LOCAL_BUILD_TYPE/crosvm /build/output/$LOCAL_CHANNEL/$LOCAL_BUILD_TYPE/
    cp /opt/$LOCAL_CHANNEL/$LOCAL_BUILD_TYPE/x86_64/lib/x86_64-linux-gnu/libgbm.* /build/output/$LOCAL_CHANNEL/$LOCAL_BUILD_TYPE/
    cp /opt/$LOCAL_CHANNEL/$LOCAL_BUILD_TYPE/x86_64/lib/x86_64-linux-gnu/libminigbm.* /build/output/$LOCAL_CHANNEL/$LOCAL_BUILD_TYPE/
  fi
fi

echo "Building 64 bit sommelier..."
cd $WORKING_DIR/cros_vm/src/platform2/vm_tools/sommelier
# Build Sommelier
mesonclean_asneeded
meson setup $LOCAL_MESON_BUILD_DIR -Dxwayland_path=/usr/bin/XWayland -Dxwayland_gl_driver_path=$WLD64/lib/x86_64-linux-gnu -Dprefix=$WLD64 && ninja -C $LOCAL_MESON_BUILD_DIR install


if [ $BUILD_KERNEL == "--true" ]; then
cd $WORKING_DIR/drm-intel
KERNEL_OUTPUT_DIR=output
if [[ ($CLEAN_BUILD == "--clean" && -d $KERNEL_OUTPUT_DIR) ]]; then
  make clean
  rm -rf $KERNEL_OUTPUT_DIR
fi

make x86_64_defconfig
make
if [ -f vmlinux ]; then
  if [ -e /build/output ]; then
    mv vmlinux /build/output/$LOCAL_CHANNEL/
  fi
fi

fi

# 32 bit builds
export ACLOCAL_PATH=$WLD32/share/aclocal
export ACLOCAL="aclocal -I $ACLOCAL_PATH"
export PKG_CONFIG_PATH=$WLD32/lib/pkgconfig:$WLD32/share/pkgconfig:/usr/lib/i386-linux-gnu/pkgconfig
export PKG_CONFIG_PATH_FOR_BUILD=$PKG_CONFIG_PATH
export PATH="$PATH:$WLD32/bin"
export CC=/usr/bin/i686-linux-gnu-gcc
export WAYLAND_PROTOCOLS_PATH=$WLD32/share/wayland-protocols
LOCAL_MESON_BUILD_DIR=build.$LOCAL_BUILD_TYPE.x86

if [ ! -f $CROSS_SETTINGS ]; then
cat > $CROSS_SETTINGS <<EOF
[binaries]
c = '/usr/bin/i686-linux-gnu-gcc'
cpp = '/usr/bin/i686-linux-gnu-g++'
ar = '/usr/bin/i686-linux-gnu-gcc-ar'
strip = '/usr/bin/i686-linux-gnu-strip'
pkgconfig = '/usr/bin/i686-linux-gnu-pkg-config'
build.pkg_config_path = '/usr/bin/i686-linux-gnu-pkg-config'

[properties]
pkg_config_libdir = '$PKG_CONFIG_PATH'
c_args = ['-m32']
c_link_args = ['-m32']
cpp_args = ['-m32']
cpp_link_args = ['-m32']

[host_machine]
system = 'linux'
cpu_family = 'x86'
cpu = 'i686'
endian = 'little'
EOF
fi

# Print all environment settings
echo "Environment settings used for 32bit builds....."
echo "Build Type:" $BUILD_TYPE
echo "Building Rust:" $BUILD_RUST
echo "Channel:" $LOCAL_CHANNEL
echo "Build Dir:" $LOCAL_MESON_BUILD_DIR
if [ $CLEAN_BUILD == "--clean" ]; then
  echo "Clean" $LOCAL_BUILD_TYPE "Build"
else
  echo "Incremental" $LOCAL_BUILD_TYPE "Build"
fi

# print gcc environment
echo "C environment settings"
i686-linux-gnu-gcc -xc -E -v
echo "---------------------------------"
echo "C++ environment settings"
i686-linux-gnu-gcc -xc++ -E -v
echo "---------------------------------"

env
echo "........................................................"

echo "checking " $WLD32/share/aclocal
if [ ! -d "$WLD32/share/aclocal" ]; then
  if [ ! -d /opt/$LOCAL_CHANNEL ]; then
    mkdir /opt/$LOCAL_CHANNEL
  fi

  if [ ! -d $BASE_DIR ]; then
    mkdir $BASE_DIR
  fi
  if [ ! -d $WLD32 ]; then
    mkdir $WLD32
  fi

  if [ ! -d "$WLD32/share" ]; then
    mkdir $WLD32/share
  fi

  mkdir $WLD32/share/aclocal
  if [ ! -d "$WLD32/share/aclocal" ]; then
    echo "Failed to create" $WLD32/share/aclocal
  fi
else
  echo $WLD32/share/aclocal "exists"
fi

echo "Building 32bit libraries....."

cd $WORKING_DIR/xorg-libpciaccess
echo "Building 32 bit libpciaccess....."
#makeclean_asneeded
make clean

./autogen.sh --host=i686-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32" --prefix=$WLD32
make install
cd $WORKING_DIR/mesa-drm

# Build libdrm
echo "Building 32 bit libdrm....."
mesonclean_asneeded
meson setup $LOCAL_MESON_BUILD_DIR -Dprefix=$WLD32 -Dintel=true -Dradeon=false -Damdgpu=false -Dnouveau=false -Domap=false -Dexynos=false -Dfreedreno=false -Dtegra=false -Dvc4=false -Detnaviv=false --buildtype $LOCAL_BUILD_TYPE --cross-file $CROSS_SETTINGS && ninja -C $LOCAL_MESON_BUILD_DIR install
cd $WORKING_DIR/wayland

# Build wayland
#makeclean_asneeded
echo "Building 32 bit wayland....."
make clean
./autogen.sh --host=i686-linux-gnu --disable-documentation "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32" --prefix=$WLD32
make install
cd $WORKING_DIR/wayland-protocols

# Build wayland-protocols
echo "Building wayland-protocols............"
#makeclean_asneeded
make clean
./autogen.sh --prefix=$WLD32
make install
cd $WORKING_DIR/xorgproto

# Build xorgproto
echo "Building xorgproto............"
mesonclean_asneeded
meson setup $LOCAL_MESON_BUILD_DIR -Dprefix="$WLD32" && ninja -C $LOCAL_MESON_BUILD_DIR install
cd $WORKING_DIR/mesa

# Build Mesa
mesonclean_asneeded
echo "Building 32 bit Mesa....." $PKG_CONFIG_PATH
meson setup $LOCAL_MESON_BUILD_DIR -Dprefix="$WLD32" -Ddri3="enabled" -Dshader-cache="enabled" -Dtools="glsl,nir" -Dplatforms="x11,wayland" -Ddri-drivers="" -Dgallium-drivers="iris,virgl,swrast" -Dvulkan-drivers="intel" -Dgallium-vdpau="disabled" -Dgallium-va="disabled" -Dopengl="true" -Dglx="dri" -Dselinux="true" -Dgles1="enabled" -Dgles2="enabled" -Dglx-direct="true" -Degl="enabled" -Dllvm="disabled" --buildtype $LOCAL_BUILD_TYPE --cross-file $CROSS_SETTINGS && ninja -C $LOCAL_MESON_BUILD_DIR install
cd $WORKING_DIR/libepoxy

# Build libepoxy
echo "Building 32 bit libepoxy....."
mesonclean_asneeded
meson setup $LOCAL_MESON_BUILD_DIR -Dprefix=$WLD32 --buildtype $LOCAL_BUILD_TYPE --cross-file $CROSS_SETTINGS && ninja -C $LOCAL_MESON_BUILD_DIR install
cd $WORKING_DIR/minigbm

# Build minigbm
#makeclean_asneeded
echo "Building 32 bit minigbm....."
make clean
make CPPFLAGS="-DDRV_I915" DRV_I915=1 "CFLAGS=-m32 -msse2 -mstackrealign" "CXXFLAGS=-m32" "LDFLAGS=-m32" install DESTDIR=$WLD32 LIBDIR=lib
cd $WORKING_DIR/virglrenderer/

# Build virglrenderer
echo "Building 32 bit virglrenderer....."
mesonclean_asneeded
meson setup $LOCAL_MESON_BUILD_DIR -Dprefix=$WLD32 -Dplatforms=auto -Dminigbm_allocation=true --buildtype $LOCAL_BUILD_TYPE --cross-file $CROSS_SETTINGS && ninja -C $LOCAL_MESON_BUILD_DIR install

