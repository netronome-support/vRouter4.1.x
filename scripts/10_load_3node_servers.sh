#!/bin/bash
# Configures .JSON config files to load servers into contrail cluster
KEY_FILE="/root/.ssh/netronome_key"
touch $KEY_FILE
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
# Control node management IP
ovc_ip="172.26.1.149"
#========COMPUTE=NODE===========
# compute node 1 management IP
cmp1_ip="172.26.1.150"
# compute node 2 management IP
cmp2_ip="172.26.1.151"
#===============================
# NO MORE CHANGES
#===============================
cntrl_dm=$cntrl.$dm
cmp1_dm=$cmp1.$dm
cmp2_dm=$cmp2.$dm
nfp_iface="nfp_p0"
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
        cp -r ${PWD}/clusterconf/* ${PWD}/confs

fi
echo "Copying keys to Compute and Control nodes"
echo " - Create Public key"
ssh-keygen -t rsa -f $KEY_FILE -q -P ""
eval `ssh-agent -s`
ssh-add $KEY_FILE
sleep 1
ssh-copy-id -i $KEY_FILE.pub root@$ovc_ip
ssh-copy-id -i $KEY_FILE.pub root@$cmp1_ip
ssh-copy-id -i $KEY_FILE.pub root@$cmp2_ip
echo "Building params for Control Node"
cntrl=$(ssh $ovc_ip 'cat /etc/hostname')
echo "Hostname: $cntrl"
cntrl_iface=$(ssh $ovc_ip "ifconfig | grep -B1 'inet addr:${ovc_ip}'" | awk '$1!="inet" {print $1}')
echo "Iface name: $cntrl_iface"
cntrl_mac=$(ssh $ovc_ip "ifconfig | grep -B1 'inet addr:${ovc_ip}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Iface mac: $cntrl_mac"
nfp_ip=$(ssh $ovc_ip "ifconfig $nfp_iface" | grep 'inet addr:' | awk '$2!="inet:" {print $2}' | cut -d ':' -f2)
echo "Nfp ip: $nfp_ip"
nfp_mac=$(ssh $ovc_ip "ifconfig | grep -B1 'inet addr:${nfp_ip}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Nfp mac: $nfp_mac"
SERVER1="${PWD}/confs/3node_cluster/control.json"
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

echo "Building params for Compute 1 Node"
cmp=$(ssh $cmp1_ip 'cat /etc/hostname')
echo "Hostname: $cmp"
cmp_iface=$(ssh $cmp1_ip "ifconfig | grep -B1 'inet addr:${cmp1_ip}'" | awk '$1!="inet" {print $1}')
echo "Iface name: $cmp_iface"
cmp_mac=$(ssh $cmp1_ip "ifconfig | grep -B1 'inet addr:${cmp1_ip}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Iface mac: $cmp_mac"
nfp_ip=$(ssh $cmp1_ip "ifconfig $nfp_iface" | grep 'inet addr:' | awk '$2!="inet:" {print $2}' | cut -d ':' -f2)
echo "Nfp ip: $nfp_ip"
nfp_mac=$(ssh $cmp1_ip "ifconfig | grep -B1 'inet addr:${nfp_ip}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Nfp mac: $nfp_mac"
SERVER2="${PWD}/confs/3node_cluster/compute1.json"
DIR='s,<cl_nm>,'$cl_nm',g'
sed -i $DIR $SERVER2
DIR='s,<dm>,'$dm',g'
sed -i $DIR $SERVER2
DIR='s,<cmp>,'$cmp',g'
sed -i $DIR $SERVER2
DIR='s,<gway>,'$gway',g'
sed -i $DIR $SERVER2
DIR='s,<cmp_ip>,'$cmp1_ip',g'
sed -i $DIR $SERVER2
DIR='s,<mgmt_mac>,'$cmp_mac',g'
sed -i $DIR $SERVER2
DIR='s,<mgmt_iface>,'$cmp_iface',g'
sed -i $DIR $SERVER2
DIR='s,<nfp_ip>,'$nfp_ip',g'
sed -i $DIR $SERVER2
DIR='s,<nfp_mac>,'$nfp_mac',g'
sed -i $DIR $SERVER2
DIR='s,<nfp_iface>,'$nfp_iface',g'
sed -i $DIR $SERVER2
server-manager add server -f $SERVER2

echo "Building params for Compute 2 Node"
cmp=$(ssh $cmp2_ip 'cat /etc/hostname')
echo "Hostname: $cmp"
cmp_iface=$(ssh $cmp2_ip "ifconfig | grep -B1 'inet addr:${cmp2_ip}'" | awk '$1!="inet" {print $1}')
echo "Iface name: $cmp_iface"
cmp_mac=$(ssh $cmp2_ip "ifconfig | grep -B1 'inet addr:${cmp2_ip}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Iface mac: $cmp_mac"
nfp_ip=$(ssh $cmp2_ip "ifconfig $nfp_iface" | grep 'inet addr:' | awk '$2!="inet:" {print $2}' | cut -d ':' -f2)
echo "Nfp ip: $nfp_ip"
nfp_mac=$(ssh $cmp2_ip "ifconfig | grep -B1 'inet addr:${nfp_ip}'" | awk '$1!="HWaddr" {print $5}' | cut -d$'\n' -f1)
echo "Nfp mac: $nfp_mac"
SERVER3="${PWD}/confs/3node_cluster/compute2.json"
DIR='s,<cl_nm>,'$cl_nm',g'
sed -i $DIR $SERVER3
DIR='s,<dm>,'$dm',g'
sed -i $DIR $SERVER3
DIR='s,<cmp>,'$cmp',g'
sed -i $DIR $SERVER3
DIR='s,<gway>,'$gway',g'
sed -i $DIR $SERVER3
DIR='s,<cmp_ip>,'$cmp2_ip',g'
sed -i $DIR $SERVER3
DIR='s,<mgmt_mac>,'$cmp_mac',g'
sed -i $DIR $SERVER3
DIR='s,<mgmt_iface>,'$cmp_iface',g'
sed -i $DIR $SERVER3
DIR='s,<nfp_ip>,'$nfp_ip',g'
sed -i $DIR $SERVER3
DIR='s,<nfp_mac>,'$nfp_mac',g'
sed -i $DIR $SERVER3
DIR='s,<nfp_iface>,'$nfp_iface',g'
sed -i $DIR $SERVER3
server-manager add server -f $SERVER3


echo "Added servers"
sleep 1
server-manager status server
