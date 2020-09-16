#! /bin/bash

# run-rootfs-builder.sh [USERNAME PASSWORD CONFIG_FILE MOUNT_POINT]
# Generate debian rootfs image using specified config file and mounted in the
# container at the specified path (should match mountPoint specified in json file)

# exit on any script line that fails
set -o errexit
# bail on any unitialized variable reads
set -o nounset
# bail on failing commands before last pipe
set -o pipefail

USER=${1:-"test"}
PASS=${2:-"test0000"}
CONFIG_FILE=${3:-"config/image.json"}
MOUNT_POINT=${4:-"mount/"}

# Create all needed directories.
if [ ! -e "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

CURRDATE=`date "+%y%m%d-%H%M"`
# Generate initial rootfs image.
echo "Generating rootfs image"
python3 scripts/create-image.py --spec $CONFIG_FILE --create --mount > >(tee -a output/image-$CURRDATE.log) 2> >(tee -a output/image-$CURRDATE.err >&2)

mkdir /app/output/stable
mkdir /app/output/master

mkdir /app/output/stable/debug
mkdir /app/output/stable/release

mkdir /app/output/master/debug
mkdir /app/output/master/release

echo "Bootstrapping debian userspace"
debootstrap --arch=amd64 testing $MOUNT_POINT > >(tee -a output/debootstrap-$CURRDATE.log) 2> >(tee -a output/debootstrap-$CURRDATE.err >&2)

echo "Configuring chroot environment"
mount -t proc /proc $MOUNT_POINT/proc
mount -o bind /dev/shm $MOUNT_POINT/dev/shm
mount -o bind /dev/pts $MOUNT_POINT/dev/pts

# Install all needed system packages.
echo "Copying script to install needed system packages in rootfs..."
cp scripts/system.sh $MOUNT_POINT/system.sh
echo "Installing system packages in rootfs...."
chroot $MOUNT_POINT/ /bin/bash -c '/system.sh > >(tee output.log) 2> >(tee output.err >&2)'
cat $MOUNT_POINT/output.log >> output/configure-$CURRDATE.log
cat $MOUNT_POINT/output.err >> output/configure-$CURRDATE.err
rm $MOUNT_POINT/system.sh

echo "Copying user configuration script..."
mkdir -p $MOUNT_POINT/deploy/config
cp scripts/user.sh $MOUNT_POINT/deploy/
cp scripts/create-users.py $MOUNT_POINT/deploy/
cp config/users.json $MOUNT_POINT/deploy/config/
echo "Configuring the user..."
chroot $MOUNT_POINT/ /bin/bash -c '/deploy/user.sh > >(tee output.log) 2> >(tee output.err >&2)'
cat $MOUNT_POINT/output.log >> output/configure-$CURRDATE.log
cat $MOUNT_POINT/output.err >> output/configure-$CURRDATE.err
rm -rf $MOUNT_POINT/deploy/

echo "Configuring rootfs..."
cp -rf config/guest/* $MOUNT_POINT/

# Enable all needed services
cp scripts/services.sh $MOUNT_POINT/services.sh
chroot $MOUNT_POINT/ /bin/bash -c '/services.sh $USER > >(tee output.log) 2> >(tee output.err >&2)'
cat $MOUNT_POINT/output.log >> output/configure-$CURRDATE.log
cat $MOUNT_POINT/output.err >> output/configure-$CURRDATE.err
rm $MOUNT_POINT/services.sh

if [ ! -e $MOUNT_POINT/build ]; then
    mkdir -p $MOUNT_POINT/build
    mkdir -p $MOUNT_POINT/build/output
fi
mount -o bind /app/output $MOUNT_POINT/build/output

# Build all UMD and user space libraries.
echo "Copying script to build Graphics drivers and other packages..."
cp scripts/builder.sh $MOUNT_POINT/builder.sh
echo "Building User Mode Graphics Drivers..."
chroot $MOUNT_POINT/ /bin/bash -c '/builder.sh --release --clean --stable --true --true --true > >(tee output.log) 2> >(tee output.err >&2)'
chroot $MOUNT_POINT/ /bin/bash -c '/builder.sh --debug --clean --stable --true > >(tee -a output.log) 2> >(tee -a output.err >&2)'
chroot $MOUNT_POINT/ /bin/bash -c '/builder.sh --release --clean --master --true --true --true > >(tee -a output.log) 2> >(tee -a output.err >&2)'
chroot $MOUNT_POINT/ /bin/bash -c '/builder.sh --debug --clean --master --true > >(tee -a output.log) 2> >(tee -a output.err >&2)'
rm $MOUNT_POINT/builder.sh
cat $MOUNT_POINT/output.log >> output/build-$CURRDATE.log
cat $MOUNT_POINT/output.err >> output/build-$CURRDATE.err

echo "Unmounting image"
python3 scripts/create-image.py --spec $CONFIG_FILE --unmount

chmod -R 777 output/

echo "Done!"
