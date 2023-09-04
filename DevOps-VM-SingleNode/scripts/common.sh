#! /bin/bash

set -euxo pipefail
echo "**** Begin installing Utilities from common ****"
# DNS Setting
sudo mkdir /etc/systemd/resolved.conf.d/
cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=${DNS_SERVERS}
EOF

# Install Utilities
sudo apt install ubuntu-desktop-minimal -y
sudo timedatectl set-timezone America/Costa_Rica
sudo apt install jq -y
sudo apt install nfs-common -y
sudo gsettings set org.gnome.desktop.session idle-delay 0



