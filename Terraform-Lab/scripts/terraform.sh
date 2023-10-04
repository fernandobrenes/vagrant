#! /bin/bash
#title        :terraform.sh
#description  :This script install terraform if it doesn't exist
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
Begin Installing Terraform from terraform\n
***********************************************${Color_Off}"

if command -v terraform > /dev/null; then
    echo -e "${Green}Terraform is already installed, trying to update${Color_Off}"
    sudo apt-get update && sudo apt-get upgrade
else
  #sudo apt install wget apt-transport-https gnupg2 software-properties-common -y
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
  wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  gpg --no-default-keyring \
  --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  --fingerprint
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
  sudo apt-get install terraform
  #sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y
  #curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  #sudo apt update -y
  #sudo apt install terraform -y
fi
