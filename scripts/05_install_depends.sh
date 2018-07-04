#!/bin/bash
# Installs dependencies for server-manager
echo "Installing server-manager dependenceies"
apt-get install -y Linux-image-extra-$(uname -r)
apt-get install -y python-babel python-cinderclient python-cryptography python-decorator
sleep 5
apt-get install -y python-nova=2:13.1.4-0ubuntu4.2 libnl-3-200=3.2.27-1 python
#apt-get install -y linux-image-extra-4.4.0-62-generic
echo "Reboot for changes to take effect..."

