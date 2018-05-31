#!/bin/bash
# Applies Netronome specific contrail patches to server-manager image

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

echo "Downloading patches"
wget http://pahome.netronome.com/releases-intern/vrouter/builds/Netronome_R4.1_build_62.tar
tar -xvf Netronome_R4.1_build_**.tar
rm -r Netronome_R4.1_build_**.tar

echo "Applying patces"
#./Netronome_R4.1_build_**/00_setup_repos.sh $IMAGE
#./Netronome_R4.1_build_**/01_patch_server_manager.sh $IMAGE
#./Netronome_R4.1_build_**/02_update_docker.sh $IMAGE

echo "Cleaning up"
rm -r Netronome_R4.1_build_**

echo "Restarting contrail"
service contrail-server-manager restart
