#!/bin/bash
# Loads Ocata openstack image

#TODO: Add check for existing image and remove from server-manager
echo "Making JSON config directory"
cd ${PWD}/../
if [ $(ls | grep "confs") == "confs" ]; then
	rm -r confs/*
else
	mkdir confs
fi

echo "Copying and updating config templates"
cp -r ${PWD}/clusterconf/* ${PWD}/confs
IMAGE="${PWD}/confs/image.json"
DIR='s,<docker_path>,'${PWD}'/contrail-cloud-docker_4.1.1.0-11-ocata_xenial.tgz,g'
sed -i $DIR $IMAGE

echo "Downloading OpenStack Image"
# Local repo version from the NAS
wget --tries=1 http://172.26.1.131/nas/vrouter4/contrail-cloud-docker_4.1.1.0-11-ocata_xenial.tgz
# Inet version from PA
#wget http://bonobo.netronome.com/vrouter/dependencies/juniper_packages/contrail-cloud-docker_4.1.1.0-11-ocata_xenial.tgz

#Check for successful file download
if [[ $? -ne 0 ]]; then
    exit 1;
fi

echo "Adding image to server manager"
#server-manager add image -f $IMAGE

echo "Waiting for image upload"
LAST="start"
while [ $(docker image list | grep main | wc -l) != "57" ]; do
	CURRENT=$(docker image list | grep main | wc -l)
	if [ "${CURRENT}" != "${LAST}" ]; then 
		echo  "Docker image no: $CURRENT"
		LAST=$CURRENT
	fi
done
sleep 20
echo "Instalation complete"
server-manager display image
