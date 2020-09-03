#! /bin/bash
USER=$1
PASS=$2

apt-get update
apt-get install lxc lxctl lxc-templates sudo ssh

echo "$PASS" | passwd root --stdin
useradd -D -G sudo $USER
echo "$PASS" | passwd "$USER" --stdin