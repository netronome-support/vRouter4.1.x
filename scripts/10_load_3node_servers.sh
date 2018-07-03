#!/bin/bash
# Configures .JSON config files to load servers into contrail cluster
KEY_FILE="/root/.ssh/netronome_key"
touch $KEY_FILE
#================================
# CHANGE THE FOLLOWING
#============CLUSTER=============
# Cluster name
CL_NM="simba_zazu"
# Domain name
DM="netronome.com"
# Default management network gateway
GWAY="172.26.0.1"
# Managment network subnet mask
MSK="255.255.252.0"
#===============================
#=========CONTROL=NODE==========
# Control node management IP
OVC_IP="172.26.1.149"
#=======COMPUTE=NODES===========
# Compute1 node management IP
CMP1_IP="172.26.1.150"
# Compute2 node management IP
CMP2_IP="172.26.1.151"
#===============================
# NO MORE CHANGES
#===============================
echo "Checking for config directory"
cd ${PWD}/../
if [ $(ls | grep "confs") == "confs" ]; then
        echo "Config directory already exists"
        cp ${PWD}/clusterconf/3node_cluster/control.json ${PWD}/confs/3node_cluster/control.json
	cp ${PWD}/clusterconf/3node_cluster/compute1.json ${PWD}/confs/3node_cluster/compute1.json
        cp ${PWD}/clusterconf/3node_cluster/compute2.json ${PWD}/confs/3node_cluster/compute2.json
else
        echo "Creating config directory"
        mkdir ${PWD}/confs
        echo "Copying and updating config templates"
        cp ${PWD}/clusterconf/* ${PWD}/confs

fi
echo "Copying keys to Compute and Control nodes"
echo " - Create Public key"
ssh-keygen -t rsa -f $KEY_FILE -q -P ""
eval `ssh-agent -s`
ssh-add $KEY_FILE
sleep 1
ssh-copy-id -i $KEY_FILE.pub root@$OVC_IP
ssh-copy-id -i $KEY_FILE.pub root@$CMP1_IP
ssh-copy-id -i $KEY_FILE.pub root@$CMP2_IP
echo "Building params for Control/Compute Node"
CNTRL=$(ssh $OVC_IP 'cat /etc/hostname')
echo "Hostname: $CNTRL"
CNTRL_IFACE=$(ssh $OVC_IP "ifconfig | grep -B1 'inet addr:${OVC_IP}'" | awk '$1!="inet" {print $1}')
echo "Iface name: $CNTRL_IFACE"
CNTRL_MAC=$(ssh $OVC_IP "ifconfig | grep -B1 'inet addr:${OVC_IP}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Iface mac: $CNTRL_MAC"
NFP_IP=$(ssh $OVC_IP "ifconfig $NFP_IFACE" | grep 'inet addr:' | awk '$2!="inet:" {print $2}' | cut -d ':' -f2)
echo "Nfp ip: $NFP_IP"
NFP_MAC=$(ssh $OVC_IP "ifconfig | grep -B1 'inet addr:${NFP_IP}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Nfp mac: $NFP_MAC"
CONTROL="${PWD}/confs/3node_cluster/control.json"
DIR='s,<cl_nm>,'$CL_NM',g'
sed -i $DIR $CONTROL
DIR='s,<dm>,'$DM',g'
sed -i $DIR $CONTROL
DIR='s,<cntrl>,'$CNTRL',g'
sed -i $DIR $CONTROL
DIR='s,<gway>,'$GWAY',g'
sed -i $DIR $CONTROL
DIR='s,<cntrl_ip>,'$OVC_IP',g'
sed -i $DIR $CONTROL
DIR='s,<mgmt_mac>,'$CNTRL_MAC',g'
sed -i $DIR $CONTROL
DIR='s,<mgmt_iface>,'$CNTRL_IFACE',g'
sed -i $DIR $CONTROL
DIR='s,<nfp_ip>,'$NFP_IP',g'
sed -i $DIR $CONTROL
DIR='s,<nfp_mac>,'$NFP_MAC',g'
sed -i $DIR $CONTROL
DIR='s,<nfp_iface>,'$NFP_IFACE',g'
sed -i $DIR $CONTROL
server-manager add server -f $CONTROL
exit -1

echo "Building params for Compute Node"
CMP=$(ssh $CMP_IP 'cat /etc/hostname')
echo "Hostname: $CMP"
CMP_IFACE=$(ssh $CMP_IP "ifconfig | grep -B1 'inet addr:${CMP_IP}'" | awk '$1!="inet" {print $1}')
echo "Iface name: $CMP_IFACE"
CMP_MAC=$(ssh $CMP_IP "ifconfig | grep -B1 'inet addr:${CMP_IP}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Iface mac: $CMP_MAC"
NFP_IP=$(ssh $CMP_IP "ifconfig $NFP_IFACE" | grep 'inet addr:' | awk '$2!="inet:" {print $2}' | cut -d ':' -f2)
echo "Nfp ip: $NFP_IP"
NFP_MAC=$(ssh $CMP_IP "ifconfig | grep -B1 'inet addr:${NFP_IP}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Nfp mac: $NFP_MAC"
SERVER2="${PWD}/confs/2node_cluster/compute.json"
DIR='s,<cl_nm>,'$CL_NM',g'
sed -i $DIR $SERVER2
DIR='s,<dm>,'$DM',g'
sed -i $DIR $SERVER2
DIR='s,<cmp>,'$CMP',g'
sed -i $DIR $SERVER2
DIR='s,<gway>,'$GWAY',g'
sed -i $DIR $SERVER2
DIR='s,<cmp_ip>,'$CMP_IP',g'
sed -i $DIR $SERVER2
DIR='s,<mgmt_mac>,'$CMP_MAC',g'
sed -i $DIR $SERVER2
DIR='s,<mgmt_iface>,'$CMP_IFACE',g'
sed -i $DIR $SERVER2
DIR='s,<nfp_ip>,'$NFP_IP',g'
sed -i $DIR $SERVER2
DIR='s,<nfp_mac>,'$NFP_MAC',g'
sed -i $DIR $SERVER2
DIR='s,<nfp_iface>,'$NFP_IFACE',g'
sed -i $DIR $SERVER2
server-manager add server -f $SERVER2

echo "Added servers"
sleep 1
server-manager status server
