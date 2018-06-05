#!/bin/bash
# Creates cluster in server-manager
#================================
# CHANGE THE FOLLOWING
#============CLUSTER=============
# Cluster name
cl_nm="atari_apple"
# Domain name
dm="netronome.com"
# Default management network gateway
gway="172.26.0.1"
# Managment network subnet mask
msk="255.255.252.0"
#===============================
#=========CONTROL=NODE==========
# Control node host name
cntrl="atari"
# Control node management IP
ovc_ip="172.26.1.51"
#========COMPUTE=NODE===========
# Compute node host name
cmp="apple"
# compute node management IP
cmp_ip="172.26.1.52"
#===============================
# NO MORE CHANGES
#===============================

#TODO: Add check for existing image and remove from server-manager 
echo "Constructing domain names"
# Control node domain
cntrl_dm="$cntrl.$dm"
# Compute node domain
cmp_dm="$cmp.$dm"

echo "Checking for config directory"
cd ${PWD}/../
if [ $(ls | grep "confs") == "confs" ]; then
	echo "Config directory already exists"
	cp ${PWD}/clusterconf/2node_cluster/cluster.json ${PWD}/confs/
else
	echo "Creating config directory"
        mkdir ${PWD}/confs
	echo "Copying and updating config templates"
	cp ${PWD}/clusterconf/2node_cluster/* ${PWD}/confs
fi
CLUSTER="${PWD}/confs/cluster.json"
DIR='s,<cl_nm>,'$cl_nm',g'
sed -i $DIR $CLUSTER
DIR='s,<dm>,'$dm',g'
sed -i $DIR $CLUSTER
DIR='s,<gway>,'$gway',g'
sed -i $DIR $CLUSTER
DIR='s,<msk>,'$msk',g'
sed -i $DIR $CLUSTER
DIR='s,<cntrl>,'$cntrl',g'
sed -i $DIR $CLUSTER
DIR='s,<cntrl_dm>,'$cntrl_dm',g'
sed -i $DIR $CLUSTER
DIR='s,<ovc_ip>,'$ovc_ip',g'
sed -i $DIR $CLUSTER
DIR='s,<cmp>,'$cmp',g'
sed -i $DIR $CLUSTER
DIR='s,<cmp_dm>,'$cmp_dm',g'
sed -i $DIR $CLUSTER
DIR='s,<cmp_ip>,'$cmp_ip',g'
sed -i $DIR $CLUSTER
server-manager add cluster -f $CLUSTER
echo "Successfully added cluster"
sleep 1
server-manager display cluster
