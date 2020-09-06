#! /bin/bash

# deploy-depends-and-configure.sh USERNAME PASSWORD
# Install support packages and configure system with specified user and password
# User will be added to the sudo, wheel, video, and audio user groups
# Root password will also match specified user's password

USER=$1
PASS=$2

apt-get update
apt-get install -y lxc lxctl lxc-templates sudo ssh

echo "root:$PASS" | chpasswd
useradd -m -s /bin/bash -G sudo,video,audio $USER
echo "$USER:$PASS" | chpasswd