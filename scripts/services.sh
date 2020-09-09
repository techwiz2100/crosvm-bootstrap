#! /bin/bash

# services.sh
# Enable needed services.

USER=$1

echo "Enabling sommelier@0.service"
sudo -u $USER systemctl --user enable sommelier@0.service
echo "Enabling sommelier@1.service"
sudo -u $USER systemctl --user enable sommelier@1.service

echo "Enabling sommelier-x@0.service"
sudo -u $USER systemctl --user enable sommelier-x@0.service
echo "Enabling sommelier-x@1.service"
sudo -u $USER systemctl --user enable sommelier-x@1.service
