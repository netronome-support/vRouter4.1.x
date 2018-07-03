#!/bin/bash
# Creates cluster in server-manager
#================================
# CHANGE THE FOLLOWING
#============CLUSTER=============
# Cluster name
cl_nm="simba_zazu_nala"
# Domain name
dm="netronome.com"
# Default management network gateway
gway="172.26.0.1"
# Managment network subnet mask
msk="255.255.252.0"
#===============================
#=========CONTROL=NODE==========
# Control node host name
cntrl="simba"
# Control node management IP
ovc_ip="172.26.1.149"
#========COMPUTE=NODEs==========
# Compute1 node host name
cmp1="zazu"
# Compute1 node management IP
cmp1_ip="172.26.1.150"
# Compute2 node host name
cmp2="nala"
# Compute2 node management IP
cmp2_ip="172.26.1.151" 
#=========NFP=IFACE=============
nfp_iface="enp2s0"
#===============================
# NO MORE CHANGES
#===============================

#TODO: Add check for existing image and remove from server-manager 
echo "Constructing domain names"
# Control node domain
cntrl_dm="$cntrl.$dm"
# Compute1 node domain
cmp1_dm="$cmp1.$dm"
# Compute2 node domain
cmp2_dm="$cmp2.$dm"
echo "Checking for config directory"
cd ${PWD}/../
if [ $(ls | grep "confs") == "confs" ]; then
	echo "Config directory already exists"
	cp ${PWD}/clusterconf/3node_cluster/cluster.json ${PWD}/confs/3node_cluster/cluster.json
else
	echo "Creating config directory"
        mkdir ${PWD}/confs
	echo "Copying and updating config templates"
	cp ${PWD}/clusterconf/* ${PWD}/confs
fi
CLUSTER="${PWD}/confs/3node_cluster/cluster.json"
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
DIR='s,<cmp1>,'$cmp1',g'
sed -i $DIR $CLUSTER
DIR='s,<cmp1_dm>,'$cmp1_dm',g'
sed -i $DIR $CLUSTER
DIR='s,<cmp1_ip>,'$cmp1_ip',g'
sed -i $DIR $CLUSTER
DIR='s,<cmp2>,'$cmp2',g'
sed -i $DIR $CLUSTER
DIR='s,<cmp2_dm>,'$cmp2_dm',g'
sed -i $DIR $CLUSTER
DIR='s,<cmp2_ip>,'$cmp2_ip',g'
sed -i $DIR $CLUSTER
DIR='s,<nfp_iface>,'$nfp_iface',g'
sed -i $DIR $CLUSTER
server-manager add cluster -f $CLUSTER
echo "Successfully added cluster"
sleep 1
server-manager display cluster
