#! /bin/bash

# deploy-depends-and-configure.sh USERNAME PASSWORD
# Install support packages and configure system with specified user and password
# User will be added to the sudo, wheel, video, and audio user groups
# Root password will also match specified user's password

USER=$1
PASS=$2

apt-get update
apt-get install lxc lxctl lxc-templates sudo ssh

echo "$PASS" | passwd root --stdin
useradd -D -G sudo,wheel,video,audio $USER
echo "$PASS" | passwd "$USER" --stdin