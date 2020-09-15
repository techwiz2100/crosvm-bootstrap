#! /bin/bash

# exit on any script line that fails
set -o errexit
# bail on any unitialized variable reads
set -o nounset
# bail on failing commands before last pipe
set -o pipefail

PWD=$PWD
if [ ! -e "build/output/rootfs.ext4" ]; then
    echo "rootfs image does not exist."
    exit
fi

MOUNT_POINT=build/output/development
echo "Configuring chroot environment"
if [ ! -e $MOUNT_POINT ]; then
    sudo mkdir -p $MOUNT_POINT
fi

if [ ! -e $MOUNT_POINT/build/output ]; then
    sudo mkdir -p $MOUNT_POINT/build/output
fi

sudo mount build/output/rootfs.ext4 $MOUNT_POINT
sudo mount -t proc /proc $MOUNT_POINT/proc
sudo mount -o bind /run/shm $MOUNT_POINT/dev/shm
sudo mount -o bind /dev/pts $MOUNT_POINT/dev/pts
sudo mount -o bind $PWD/build/output/ $MOUNT_POINT/build/output 

sudo cp $PWD/scripts/package-builder.sh $MOUNT_POINT/build/
sudo chroot $MOUNT_POINT su -

echo "unmounting /proc /dev/shm /dev/pts"
sudo umount -l $MOUNT_POINT/proc
sudo umount -l $MOUNT_POINT/dev/shm
sudo umount -l $MOUNT_POINT/dev/pts
sudo umount -l $MOUNT_POINT/build/output
sudo umount -l $MOUNT_POINT
