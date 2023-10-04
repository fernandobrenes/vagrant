#! /bin/bash
#title        :docker.sh
#description  :This script install aws cli if it doesn't exist
#author       :Fernando Brenes
#date         :2023-09-11
#version      :1.0.0
#notes        :This script has no dependencies
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
Begin Installing Docker\n
***********************************************${Color_Off}"

if command -v docker > /dev/null; then
    echo -e "${Green}Docker is already installed, you may update manually if needed${Color_Off}"
else
    # INSTALL DOCKER BASED ON OS 
    OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    if [[ $OS == '"Ubuntu"' ]]; then
        echo -e "${Green}Ubuntu OS Detected, installing Docker${Color_Off}"
        
        # Clean Install Docker Engine on Ubuntu / Include also Kubernetes Packages required
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
        sudo apt-get update -y
        sudo apt-get upgrade -y
        sudo apt-get install -y \
            ca-certificates \
            curl \
            gnupg2 \
            gnupg \
            lsb-release \
            apt-transport-https \
            software-properties-common

        # Add Docker’s official GPG key:
        sudo mkdir -m 0755 -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # Set up the stable repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        #Install Docker Engine
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        sudo apt-get update -y
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

        # Run Docker Rootless Mode
        if getent group docker 2>&1 > /dev/null || grep -q docker /etc/group; then
          echo -e "${Green}Docker group exist${Color_Off}"
        else
          sudo groupadd docker
        fi
        sudo usermod -aG docker $USER
        sudo gpasswd -a vagrant docker

        # Configure Docker to start on boot with systemd
        sudo systemctl enable docker.service
        sudo systemctl enable containerd.service

    elif [[ $OS == '"Debian GNU/Linux"' ]]; then
        echo -e "${Green}Debian OS Detected, installing Docker${Color_Off}"
        
        # Clean Install Docker Engine on Ubuntu / Include also Kubernetes Packages required
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
        sudo apt-get update -y
        sudo apt-get upgrade -y
        sudo apt-get install -y \
            ca-certificates \
            curl \
            gnupg2 \
            gnupg \
            lsb-release \
            apt-transport-https \
            software-properties-common
        
        # Add Docker's official GPG key:
        sudo apt-get update -y
        sudo apt-get install ca-certificates curl gnupg -y
        sudo mkdir -m 0755 -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Add the repository to Apt sources:
        echo \
          "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
          "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update -y
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

        # Run Docker Rootless Mode
        if getent group docker 2>&1 > /dev/null || grep -q docker /etc/group; then
          echo -e "${Green}Docker group exist${Color_Off}"
        else
          sudo groupadd docker
        fi
        sudo usermod -aG docker $USER
        sudo gpasswd -a vagrant docker

        # Configure Docker to start on boot with systemd
        sudo systemctl enable docker.service
        sudo systemctl enable containerd.service

    else
        echo -e "${Red}Uknown OS${Color_Off}"
        exit 1
    fi
fi