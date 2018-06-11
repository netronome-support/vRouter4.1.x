#!/bin/bash
# Installs dependencies for server-manager
echo "Installing server-manager dependenceies"
apt-get install -y Linux-image-extra-$(uname -r)
apt-get install -y python-babel python-cinderclient python-cryptography python-decorator
echo "Reboot for changes to take effect..."

