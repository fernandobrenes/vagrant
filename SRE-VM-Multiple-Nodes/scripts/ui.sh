#! /bin/bash

set -euxo pipefail
echo "**** Begin installing UI ****"

# Install Utilities
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install ubuntu-desktop-minimal -y