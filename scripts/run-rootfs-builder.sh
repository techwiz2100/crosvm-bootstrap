#! /bin/bash

# run-rootfs-builder.sh USERNAME PASSWORD [CONFIG_FILE] [MOUNT_POINT]
# Generate debian rootfs image using specified config file and mounted in the
# container at the specified path (should match mountPoint specified in json file)

USER=${1:-"test"}
PASS=${2:-"test0000"}
CONFIG_FILE=${3:-"config/image.json"}
MOUNT_POINT=${4:-"mount/"}

if [ ! -e "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

echo "Generating rootfs image"
python3 scripts/create-image.py --spec $CONFIG_FILE

echo "Bootstrapping debian userspace"
debootstrap --arch=amd64 testing $MOUNT_POINT

echo "Copying deployment script and configuring target system"
cp scripts/deploy.sh $MOUNT_POINT/run.sh
cp -rf config/guest/* $MOUNT_POINT/
mount -t proc /proc $MOUNT_POINT/proc
mount -o bind /dev/shm $MOUNT_POINT/dev/shm
chroot $MOUNT_POINT/ /bin/bash /run.sh $USER $PASS
rm $MOUNT_POINT/run.sh
umount $MOUNT_POINT/proc
umount $MOUNT_POINT/dev/shm

echo "Unmounting image"
python3 scripts/create-image.py --spec $CONFIG_FILE --unmount

echo "Done!"
