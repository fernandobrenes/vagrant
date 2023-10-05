#! /bin/bash
#title        :kubernetes.sh
#description  :This script install Kubernetes if it doesn't exist
#author       :Fernando Brenes
#date         :2023-09-11
#version      :1.0.0
#notes        :This script has docker as a dependency
set -euxo pipefail

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Cyan='\033[0;36m'         # Cyan
Color_Off='\033[0m'       # Text Reset

echo -e "${Cyan}***********************************************\n
Begin OpenLens\n
***********************************************${Color_Off}"
if command -v open-lens > /dev/null; then
    echo -e "${Green}Open Lens is already installed${Color_Off}"
else
	OPENLENS_VERSION=$(curl -s https://api.github.com/repos/MuhammedKalkan/OpenLens/releases/latest | sed -En 's/  "tag_name": "(.+)",/\1/p')
    OPENLENS_DOWNLOAD=${OPENLENS_VERSION#v}
    wget https://github.com/MuhammedKalkan/OpenLens/releases/download/$OPENLENS_VERSION/OpenLens-$OPENLENS_DOWNLOAD.amd64.deb
    sudo apt install ./OpenLens-$OPENLENS_DOWNLOAD.amd64.deb
fi