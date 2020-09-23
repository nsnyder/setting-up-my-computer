#!/usr/bin/env bash

# Do installation for linux.

apt update && apt upgrade
apt install network-manager

# Remove these, because they conflict with network-manager.
apt purge -qq openresolv dhcpcd5

# Setup locast2plex.
sudo $1../locast2plex/install.sh $1../locast2plex $2

# Copy this file, and make it executable.
# It must be copied, not symlinked, because NetworkManager requires regular files to work.
cp $1../network-manager/99-wifi /etc/NetworkManager/dispatcher.d/99-wifi
chown root:root /etc/NetworkManager/dispatcher.d/99-wifi
chmod +x /etc/NetworkManager/dispatcher.d/99-wifi

cp $1../network-manager/crda /etc/default/crda
chown root:root /etc/default/crda

# To handle symlinks correctly, do like so:
# ln -sf $1../network-manager/99-wifi /etc/NetworkManager/dispatcher.d/99-wifi
