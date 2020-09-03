#! /bin/bash
python3 scripts/create-image.py --spec config/image.json
debootstrap testing mount/
cp scripts/deploy-depends-and-configure.sh mount/run.sh
chroot mount/ run.sh $@
rm mount/run.sh
cp -rf config/etc mount/etc
python3 scripts/create-image.py --spec config/image.json --unmount
