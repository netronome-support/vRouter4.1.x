#!/bin/bash
# Configures .JSON config files to load servers into contrail cluster
KEY_FILE="/root/.ssh/netronome_key"
touch $KEY_FILE
#================================
# CHANGE THE FOLLOWING
#============CLUSTER=============
# Cluster name
cl_nm="simba_zazu"
# Domain name
dm="netronome.com"
# Default management network gateway
gway="172.26.0.1"
# Managment network subnet mask
msk="255.255.252.0"
#===============================
#=========CONTROL=NODE==========
# Control node management IP
ovc_ip="172.26.1.149"
#========COMPUTE=NODE===========
# compute node management IP
cmp_ip="172.26.1.150"
#===============================
# NO MORE CHANGES
#===============================
cmtrl_dm=$cntrl.$dm
cmp_dm=$cmp.$dm
nfp_iface="enp2s0"
echo "Checking for config directory"
cd ${PWD}/../
if [ $(ls | grep "confs") == "confs" ]; then
        echo "Config directory already exists"
        cp ${PWD}/clusterconf/2node_cluster/control.json ${PWD}/confs/2node_cluster/control.json
	cp ${PWD}/clusterconf/2node_cluster/compute.json ${PWD}/confs/2node_cluster/compute.json
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
ssh-copy-id -i $KEY_FILE.pub root@$ovs_ip
ssh-copy-id -i $KEY_FILE.pub root@$cmp_ip
echo "Building params for Control/Compute Node"
cntrl=$(ssh $ovc_ip 'cat /etc/hostname')
echo "Hostname: $CNTRL"
cntrl_iface=$(ssh $ovc_ip "ifconfig | grep -B1 'inet addr:${ovc_ip}'" | awk '$1!="inet" {print $1}')
echo "Iface name: $cntrl_iface"
cntrl_mac=$(ssh $ovc_ip "ifconfig | grep -B1 'inet addr:${ovc_ip}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Iface mac: $cntrl_mac"
nfp_ip=$(ssh $ovs_ip "ifconfig $nfp_iface" | grep 'inet addr:' | awk '$2!="inet:" {print $2}' | cut -d ':' -f2)
echo "Nfp ip: $nfp_ip"
nfp_mac=$(ssh $ovs_ip "ifconfig | grep -B1 'inet addr:${nfp_ip}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Nfp mac: $nfp_mac"
SERVER1="${PWD}/confs/2node_cluster/control.json"
DIR='s,<cl_nm>,'$cl_nm',g'
sed -i $DIR $SERVER1
DIR='s,<dm>,'$dm',g'
sed -i $DIR $SERVER1
DIR='s,<cntrl>,'$cntrl',g'
sed -i $DIR $SERVER1
DIR='s,<gway>,'$gway',g'
sed -i $DIR $SERVER1
DIR='s,<cntrl_ip>,'$ovc_ip',g'
sed -i $DIR $SERVER1
DIR='s,<mgmt_mac>,'$cntrl_mac',g'
sed -i $DIR $SERVER1
DIR='s,<mgmt_iface>,'$cntrl_iface',g'
sed -i $DIR $SERVER1
DIR='s,<nfp_ip>,'$nfp_ip',g'
sed -i $DIR $SERVER1
DIR='s,<nfp_mac>,'$nfp_mac',g'
sed -i $DIR $SERVER1
DIR='s,<nfp_iface>,'$nfp_iface',g'
sed -i $DIR $SERVER1
server-manager add server -f $SERVER1

echo "Building params for Compute Node"
cmp=$(ssh $cmp_ip 'cat /etc/hostname')
echo "Hostname: $CMP"
CMP_IFACE=$(ssh $CMP_IP "ifconfig | grep -B1 'inet addr:${CMP_IP}'" | awk '$1!="inet" {print $1}')
echo "Iface name: $CMP_IFACE"
CMP_MAC=$(ssh $CMP_IP "ifconfig | grep -B1 'inet addr:${CMP_IP}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Iface mac: $CMP_MAC"
NFP_IP=$(ssh $CMP_IP "ifconfig $NFP_IFACE" | grep 'inet addr:' | awk '$2!="inet:" {print $2}' | cut -d ':' -f2)
echo "Nfp ip: $NFP_IP"
NFP_MAC=$(ssh $CMP_IP "ifconfig | grep -B1 'inet addr:${NFP_IP}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Nfp mac: $nfp_mac"
SERVER2="${PWD}/confs/2node_cluster/compute.json"
DIR='s,<cl_nm>,'$cl_nm',g'
sed -i $DIR $SERVER2
DIR='s,<dm>,'$dm',g'
sed -i $DIR $SERVER2
DIR='s,<cmp>,'$cmp',g'
sed -i $DIR $SERVER2
DIR='s,<gway>,'$gway',g'
sed -i $DIR $SERVER2
DIR='s,<cmp_ip>,'$cmp_ip',g'
sed -i $DIR $SERVER2
DIR='s,<mgmt_mac>,'$cmp_mac',g'
sed -i $DIR $SERVER2
DIR='s,<mgmt_iface>,'$cmp_iface',g'
sed -i $DIR $SERVER2
DIR='s,<nfp_ip>,'$nfp_iface',g'
sed -i $DIR $SERVER2
DIR='s,<nfp_mac>,'$nfp_mac',g'
sed -i $DIR $SERVER2
DIR='s,<nfp_iface>,'$nfp_iface',g'
sed -i $DIR $SERVER2
server-manager add server -f $SERVER2

echo "Added servers"
sleep 1
server-manager status server
