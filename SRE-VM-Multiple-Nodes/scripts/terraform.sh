#! /bin/bash

set -euxo pipefail
echo "**** Begin installing Terraform ****"

# Install Terraform
sudo apt install wget apt-transport-https gnupg2 software-properties-common -y
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt update -y
sudo apt install terraform -y