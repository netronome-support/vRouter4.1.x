#!/bin/bash
CNTRL_IP=$1
echo "Restarting Nova on: $CNTRL_IP"
echo "Stopping NS-vrouter"
ssh $CNTRL_IP '/opt/netronome/bin/ns-vrouter-ctl stop'
sleep 5
echo "Checking vhost0"
ssh $CNTRL_IP "ifconfig vhost0"
sleep 5
echo "Stopping contrail vrouter agent"
ssh $CNTRL_IP 'service contrail-vrouter-agent stop'
sleep 5
echo "Restarting ns-vrouter"
ssh $CNTRL_IP 'ns-vrouter-ctl restart'
sleep 5
echo "Restarting networking"
ssh $CNTRL_IP 'service networking restart'
sleep 5
echo "Restarting nova compute"
ssh $CNTRL_IP 'systemctl restart nova-compute'
sleep 5
echo "Service contrail-vrouter-agent start"
ssh $CNTRL_IP 'service contrail-vrouter-agent start'
