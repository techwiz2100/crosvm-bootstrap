#! /bin/bash

# services.sh
# Enable needed services.

USER=$1

echo "Enabling sommelier@0.service"
sudo -u $USER systemctl --user enable sommelier-stable@0.service
echo "Enabling sommelier@1.service"
sudo -u $USER systemctl --user enable sommelier-stable@1.service

echo "Enabling sommelier-x@0.service"
sudo -u $USER systemctl --user enable sommelier-stable-x@0.service
echo "Enabling sommelier-x@1.service"
sudo -u $USER systemctl --user enable sommelier-stable-x@1.service

sudo loginctl enable-linger $USER
