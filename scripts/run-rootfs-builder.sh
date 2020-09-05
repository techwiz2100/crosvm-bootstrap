#! /bin/bash

# run-rootfs-builder.sh USERNAME PASSWORD [CONFIG_FILE] [MOUNT_POINT]
# Generate debian rootfs image using specified config file and mounted in the
# container at the specified path (should match mountPoint specified in json file)

if [[ $# -lt 2 ]]; then
    echo "Usage: run-rootfs-builder.sh USERNAME PASSWORD [CONFIG_FILE] [MOUNT_POINT]"
    exit 1
fi

USER=$1
PASS=$2
CONFIG_FILE=${3:-"config/image.json"}
MOUNT_POINT=${4:-"mount/"}

echo "Generating rootfs image"
python3 scripts/create-image.py --spec $CONFIG_FILE

echo "Bootstrapping debian userspace"
debootstrap testing $MOUNT_POINT

echo "Copying deployment script and configuring target system"
cp scripts/deploy-depends-and-configure.sh $MOUNT_POINT/run.sh
chroot $MOUNT_POINT/ run.sh $USER $PASS
rm $MOUNT_POINT/run.sh
cp -rf config/guest/* $MOUNT_POINT/

echo "Unmounting image"
python3 scripts/create-image.py --spec $CONFIG_FILE --unmount

echo "Done!"