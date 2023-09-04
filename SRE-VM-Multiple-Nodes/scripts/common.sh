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



