#!/bin/bash

#================================
# CHANGE THE FOLLOWING
#=========CONTROL=NODE==========
# Control node management IP
OVC_IP="172.26.1.51"
#===============================
# NO MORE CHANGES
#===============================

KEY_FILE="root/.ssh/id_rsa"
echo "Copying keys to Compute and Control nodes"
if [ ! -f $KEYFILE ]; then
    echo " - Create Public key"
    ssh-keygen -t rsa -f $KEY_FILE -q -P ""
    ssh-add $KEY_FILE
fi
ssh-copy-id -f root@$OVC_IP
server-manager provision -F --cluster_id atari_apple ocata
tail -f /var/log/contrail-server-manager/debug.log | tee /dev/tty  | awk '/Waiting for nova-compute service up/ {system("./$PWD/utils/02_restart_nova.sh $CNTRL_IP") }' | awk '/Process done/ {system("exit") }'
