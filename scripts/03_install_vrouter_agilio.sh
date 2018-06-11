#!/bin/bash
# Script to install Agilio NFP drivers for vRouter4.1.1.
mkdir NFP
cd NFP

# Build names and dirs for build versions
BUILD_VER=71
CONTRAIL_VER=4.1
BUILD_NAME="Netronome_R${CONTRAIL_VER}_build_${BUILD_VER}"

# Download driver files
echo "Downloading NFP drivers"
wget http://pahome.netronome.com/releases-intern/vrouter/builds/${BUILD_NAME}.tar

# Extract and install driver package
echo "Installing driver"
tar -xvf ${BUILD_NAME}.tar

# Install dependencies
echo "Installing depends"
cd ${BUILD_NAME}/repo_setup/debs/dependencies
dpkg -i *.deb
apt-get install -y -f
apt-get autoremove -y

# Installing NFP packages
echo "Installing NFP packages"
cd ..
dpkg -i agilio-nfp-driver-dkms_2018.**.**.****.237fdbb_all.deb\
	 ns-agilio-vrouter-udev_4.1.0.0-*.deb agilio-nic-firmware-2.0.7-1.deb\
	 nfp-bsp-6000-b0_2018.**.**.****-1_amd64.deb 
apt-get install -y -f
#dpkg -i agilio-nfp-driver-dkms_2018.**.**.****.237fdbb_all.deb\
#	ns-agilio-vrouter-udev_4.1.0.0-*.deb agilio-nic-firmware-2.0.7-1.deb\
#	nfp-bsp-6000-b0_2018.**.**.****-1_amd64.deb 

# Configure drivers to load on startup
echo "Configuring initramfs"
/opt/netronome/libexec/write_udev_rules.sh
cat /etc/udev/rules.d/90-netronome.udev.rules
update-initramfs -u

# Cleaning up
echo "Cleaning lose ends"
cd ..
cd ..
cd ..
cd ..
rm -r NFP/${BUILD_NAME}.tar

# Reload NFP drivers
echo "Reloading drivers"
rmmod nfp
modprobe nfp
