#! /bin/bash

# user-configuration.sh
# Calls create-users.py from deploy dir in rootfs with /deploy/config/users.json

cd /deploy/
./create-users.py

