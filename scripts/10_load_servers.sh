#!/bin/bash
# Configures .JSON config files to load servers into contrail cluster
KEY_FILE="root/.ssh/id_rsa"
CL_NM=atari_apple
DM=netronome.com
GWAY=172.26.0.1
MSK=255.255.252.0
CNTRL_DM=$cntrl.$dm
CMP_DM=$cmp.$dm
OVC_IP=172.26.1.51
CMP_IP=172.26.1.52
NFP_IFACE="nfp_p1"
echo "Checking for config directory"
cd ${PWD}/../
if [ $(ls | grep "confs") == "confs" ]; then
        echo "Config directory already exists"
        cp ${PWD}/clusterconf/2node_cluster/server1.json ${PWD}/confs/
	cp ${PWD}/clusterconf/2node_cluster/server2.json ${PWD}/confs/
else
        echo "Creating config directory"
        mkdir ${PWD}/confs
        echo "Copying and updating config templates"
        cp ${PWD}/clusterconf/2node_cluster/* ${PWD}/confs

fi
echo "Copying keys to Compute and Control nodes"
if [ ! -f $KEYFILE ]; then
    echo " - Create Public key"
    ssh-keygen -t rsa -f $KEY_FILE -q -P ""
    ssh-add $KEY_FILE
fi
ssh-copy-id -f root@$OVC_IP
ssh-copy-id -f root@$CMP_IP


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
SERVER1="${PWD}/confs/server1.json"
DIR='s,<cl_nm>,'$CL_NM',g'
sed -i $DIR $SERVER1
DIR='s,<dm>,'$DM',g'
sed -i $DIR $SERVER1
DIR='s,<cntrl>,'$CNTRL',g'
sed -i $DIR $SERVER1
DIR='s,<gway>,'$GWAY',g'
sed -i $DIR $SERVER1
DIR='s,<cntrl_ip>,'$OVC_IP',g'
sed -i $DIR $SERVER1
DIR='s,<mgmt_mac>,'$CNTRL_MAC',g'
sed -i $DIR $SERVER1
DIR='s,<mgmt_iface>,'$CNTRL_IFACE',g'
sed -i $DIR $SERVER1
DIR='s,<nfp_ip>,'$NFP_IP',g'
sed -i $DIR $SERVER1
DIR='s,<nfp_mac>,'$NFP_MAC',g'
sed -i $DIR $SERVER1
DIR='s,<nfp_iface>,'$NFP_IFACE',g'
sed -i $DIR $SERVER1
server-manager add server -f $SERVER1

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
SERVER2="${PWD}/confs/server2.json"
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
