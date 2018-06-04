#!/bin/bash
CNTRL_IP=$1
echo "Restarting Nova on: $CNTRL_IP"
echo "Stopping ns-vrouter"
ssh $CNTRL_IP 'ns-vrouter-ctl stop'
echo "Stopping contrail vrouter agent"
ssh $CNTRL_IP 'Service contrail-vrouter-agent stop'
echo "Restarting ns-vrouter"
ssh $CNTRL_IP 'ns-vrouter-ctl restart'
echo "Restarting networking"
ssh $CNTRL_IP 'service networking restart'
echo "Restarting nova compute"
ssh $CNTRL_IP 'systemctl restart nova-compute'
echo "Service contrail-vrouter-agent start"
ssh $CNTRL_IP 'service contrail-vrouter-agent start'
