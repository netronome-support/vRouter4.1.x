#!/bin/bash
# Applies Netronome specific contrail patches to server-manager image
BUILD_VER=71
CONTRAIL_VER=4.1
BUILD_NAME="Netronome_R${CONTRAIL_VER}_build_${BUILD_VER}"

# First test for image name argument
if [ -z "$1" ]; then
        # If no input then default to ocata
        IMAGE="ocata"
        echo "Default Image:$IMAGE"
else
        #Otherwise set image to argument
        IMAGE="$1"
fi

# Test for image existence of $IMAGE name
if [ "$(server-manager display image | grep 'ocata' | cut -d " " -f2 | cut -d " " -f1)" != $IMAGE ]; then
        # If no server-manager image exists then exit
        echo "No server-manager image named $IMAGE exists"
        exit -1
fi

# Download and extract vrouter build files
echo "Downloading patches"
wget http://pahome.netronome.com/releases-intern/vrouter/builds/${BUILD_NAME}.tar
tar -xvf Netronome_R4.1_build_**.tar
rm -r Netronome_R4.1_build_**.tar

# Apply patches to image
echo "Applying patces"
cd Netronome_R4.1_build_**
./00_setup_repos.sh $IMAGE
#./01_patch_server_manager.sh $IMAGE
./02_update_docker.sh $IMAGE

echo "Cleaning up"
cd ..
rm -r Netronome_R4.1_build_**
sleep 5
echo "Restarting contrail"
systemctl restart contrail-server-manager

