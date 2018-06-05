#!/bin/bash 
# Script to install SMLink on Orchestrator
LOCAL_HOST=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
echo "Local host IP: $LOCAL_HOST"
# Download package
echo "Downloading contrail package"
# Local repo version from the NAS
wget http://172.26.1.131/nas/vrouter4/contrail-server-manager-installer_4.1.1.0-11_ubuntu-16-04ocata_all.deb
# Inet version from PA
#wget http://bonobo.netronome.com/vrouter/dependencies/juniper_packages/contrail-server-manager-installer_4.1.1.0-11_ubuntu-16-04ocata_all.deb

# Install package
echo "Installing contrail Server-Manager"
dpkg -i contrail-server-manager-installer_4.1.1.0-11_ubuntu-16-04ocata_all.deb

# Start contrail setup and watch it's deployment
echo "Starting contrail install"
/opt/contrail/contrail_server_manager/setup.sh --all --smlite --hostip=$LOCAL_HOST

# Monitor installation and wait until installation is complete
tail -f `find /var/log/contrail/install_logs | sort -r | head -1` | tee /dev/tty | awk '/SM installation took/ {system("pkill tail")}'

# Restart contrail service
echo "Restarting contrail"
service contrail-server-manager restart

# Clean up lose ends
echo "Cleaning up"
rm -r contrail-server-manager-installer_4.1.1.0-11_ubuntu-16-04ocata_all.deb
