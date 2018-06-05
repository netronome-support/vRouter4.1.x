#!/bin/bash
# Cleans the server-manager machine 
# On server manager if SMLite was installed, delete all servers
for entry in $(server-manager display server | tail -4 | head -3 | awk '{print $2}'); do 
	echo "Deleting server: $entry"
	server-manager delete server --server_id $entry
done
# Then delete the server manager cluster
for entry in $(server-manager display cluster | tail -4 | head -3 | awk '{print $2}'); do
	if [ "$entry" != "id" ]; then
		echo "Deleting cluster: $entry"
		server-manager delete cluster --cluster_id $entry
	fi
done
# Removes all contrail installations
dpkg -l | awk '/contrail/ {print $2}' | xargs -Iz dpkg -r z
