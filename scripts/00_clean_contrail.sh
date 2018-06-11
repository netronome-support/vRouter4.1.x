#!/bin/bash
#Remove installs for Contrail packages
echo "Uninstalling Contrail specific packages"
apt remove -y $(dpkg -l | grep -i cloud0 | awk '{print $2}')

# Removes previous residuals of Contrail install on node
echo "Cleaning Contrail lists"
for files in /etc/apt/sources.list.d/*; do
        if [[ $(echo $(printf "%s" $files | grep "contrail_repo")) != '' ]]; then
                rm -r $files
        fi
done

# Update package manager to remove any conflicts
apt-get update

