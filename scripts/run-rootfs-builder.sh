#! /bin/bash

# run-rootfs-builder.sh [USERNAME PASSWORD CONFIG_FILE MOUNT_POINT]
# Generate debian rootfs image using specified config file and mounted in the
# container at the specified path (should match mountPoint specified in json file)

USER=${1:-"test"}
PASS=${2:-"test0000"}
CONFIG_FILE=${3:-"config/image.json"}
MOUNT_POINT=${4:-"mount/"}

# Create all needed directories.
if [ ! -e "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# Generate initial rootfs image.
echo "Generating rootfs image"
python3 scripts/create-image.py --spec $CONFIG_FILE --create --mount

echo "Bootstrapping debian userspace"
debootstrap --arch=amd64 testing $MOUNT_POINT

echo "Configuring chroot environment"
mount -t proc /proc $MOUNT_POINT/proc
mount -o bind /dev/shm $MOUNT_POINT/dev/shm
mount -o bind /dev/pts $MOUNT_POINT/dev/pts

# Install all needed system packages.
echo "Copying script to install needed system packages in rootfs..."
cp scripts/system.sh $MOUNT_POINT/system.sh
echo "Installing system packages in rootfs...."
chroot $MOUNT_POINT/ /bin/bash /system.sh
rm $MOUNT_POINT/system.sh

echo "Copying user configuration script..."
mkdir -p $MOUNT_POINT/deploy/config
cp scripts/user.sh $MOUNT_POINT/deploy/
cp scripts/create-users.py $MOUNT_POINT/deploy/
cp config/users.json $MOUNT_POINT/deploy/config/
echo "Configuring the user..."
chroot $MOUNT_POINT/ /bin/bash /deploy/user.sh
rm -rf $MOUNT_POINT/deploy/

echo "Configuring rootfs..."
cp -rf config/guest/* $MOUNT_POINT/

# Enable all needed services
cp scripts/services.sh $MOUNT_POINT/services.sh
chroot $MOUNT_POINT/ /bin/bash /services.sh $USER
rm $MOUNT_POINT/services.sh

# Ensure all directories and mount points are setup.
cp scripts/setup-build-directories.sh $MOUNT_POINT/setup-build-directories.sh
chroot $MOUNT_POINT/ /bin/bash /setup-build-directories.sh
rm $MOUNT_POINT/setup-build-directories.sh

# Build all UMD and user space libraries.
echo "Copying script to build Graphics drivers and other packages..."
mount -o bind /app/patches $MOUNT_POINT/build/patches
cp scripts/builder.sh $MOUNT_POINT/builder.sh
echo "Building User Mode Graphics Drivers..."
chroot $MOUNT_POINT/ /bin/bash /builder.sh --release --clean --stable --true --true
chroot $MOUNT_POINT/ /bin/bash /builder.sh --debug --clean --stable --true
chroot $MOUNT_POINT/ /bin/bash /builder.sh --release --clean --master --true
chroot $MOUNT_POINT/ /bin/bash /builder.sh --debug --clean --master --true
rm $MOUNT_POINT/builder.sh

# Build Kernel and cros_vm.
mount -o bind /app/drm-intel $MOUNT_POINT/build/drm-intel
cp scripts/build-kernel-crosvm.sh $MOUNT_POINT/build-kernel-crosvm.sh
chroot $MOUNT_POINT/ /bin/bash /build-kernel-crosvm.sh
rm $MOUNT_POINT/build-kernel-crosvm.sh
mkdir /app/output/stable
mkdir /app/output/stable/debug
mkdir /app/output/stable/release

mkdir /app/output/master
mkdir /app/output/master/debug
mkdir /app/output/master/release

if [ -f $MOUNT_POINT/build/drm-intel/vmlinux ]; then
  echo "Copying Kernel image to output/ folder..."
  cp $MOUNT_POINT/build/drm-intel/vmlinux /app/output/stable/
  cp $MOUNT_POINT/build/drm-intel/vmlinux /app/output/master/
else
  echo "Kernel failed to built. Nothing to copy."
fi

  echo "Copying crosvm to output/ folder..."
cp $MOUNT_POINT/opt/stable/release/lib/x86_64-linux-gnu/libgbm.* /app/output/stable/release/
cp $MOUNT_POINT/opt/stable/release/lib/x86_64-linux-gnu/libminigbm.* /app/output/stable/release/
cp $MOUNT_POINT/build/stable/cros_vm/src/platform/crosvm/build.release.x86_64/target/release/crosvm /app/output/stable/release/
cp $MOUNT_POINT/opt/stable/debug/lib/x86_64-linux-gnu/libgbm.* /app/output/stable/debug/
cp $MOUNT_POINT/opt/stable/debug/lib/x86_64-linux-gnu/libminigbm.* /app/output/stable/debug/
cp $MOUNT_POINT/build/stable/cros_vm/src/platform/crosvm/build.debug.x86_64/target/debug/crosvm /app/output/stable/debug/

cp $MOUNT_POINT/opt/master/release/lib/x86_64-linux-gnu/libgbm.* /app/output/master/release/
cp $MOUNT_POINT/opt/master/release/lib/x86_64-linux-gnu/libminigbm.* /app/output/master/release/
cp $MOUNT_POINT/build/master/cros_vm/src/platform/crosvm/build.release.x86_64/target/release/crosvm /app/output/master/release/
cp $MOUNT_POINT/opt/master/debug/lib/x86_64-linux-gnu/libgbm.* /app/output/master/debug/
cp $MOUNT_POINT/opt/master/debug/lib/x86_64-linux-gnu/libminigbm.* /app/output/master/debug/
cp $MOUNT_POINT/build/master/cros_vm/src/platform/crosvm/build.debug.x86_64/target/debug/crosvm /app/output/master/debug/

echo "Unmounting image"
python3 scripts/create-image.py --spec $CONFIG_FILE --unmount

echo "Done!"
