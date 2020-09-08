#! /bin/bash

# build-rootfs-builder-container.sh
# Set up build environment for docker container that generates Debian rootfs
# then calls docker#! /bin/bash

# deploy-depends-and-configure.sh USERNAME PASSWORD
# User will be added to the sudo, audio, video, input,
# render and lp user groups. Root password will also match
# specified user's password.

USER=$1
PASS=$2

echo "root:$PASS" | chpasswd
useradd -m -s /bin/bash -G sudo,audio,video,input,render,lp $USER
echo "$USER:$PASS" | chpasswd

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

