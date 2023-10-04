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
Begin Kubernetes\n
***********************************************${Color_Off}"

# SAVE KUBERNETES INFO IN DEVELOPMENT FOLDER 
DIR=/development/kubernetes
if [[ ! -d "$DIR" ]]; then
    sudo mkdir -p /development/kubernetes
    sudo chmod -R 2775 /development/kubernetes
else
    echo -e "${Green}/development/kubernetes already exist${Color_Off}"
fi

if command -v kubectl > /dev/null; then
  echo -e "${Green}kubectl is already installed, you may upgrade manually${Color_Off}"
else
  # INSTALL KUBECTL
  sudo apt-get update
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl

  # SET AUTO COMPLETION
  sudo apt-get install bash-completion -y
  echo 'source <(kubectl completion bash)' >> ~/.bashrc
  echo 'alias k=kubectl' >> ~/.bashrc
  echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
fi

if command -v helm > /dev/null; then
  echo -e "${Green}helm is already installed, you may upgrade manually${Color_Off}"
else
  # INSTALL HELM
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm
fi

if command -v kind > /dev/null; then
  echo -e "${Green}Kind is already installed, you may upgrade manually${Color_Off}"
else
  # KIND_VERSION=$(grep -E '^\s*kind:' /mnt/myshare/settings.yaml | sed -E 's/[^:]+: *//' | tr -d '\012\015') From settings.yaml
  KIND_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | sed -En 's/  "tag_name": "(.+)",/\1/p')
  
  # INSTALL KIND
  sudo [ $(uname -m) = x86_64 ] && curl -Lo /tmp/kind https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-amd64
  chmod +x /tmp/kind
  sudo mv /tmp/kind /usr/local/bin/kind
fi

# CREATE CLUSTER YAML - https://itnext.io/kubernetes-kind-cheat-shee-2605da77984
CLUSTER=/development/kubernetes/cluster-create.yml
if [[ ! -f "$CLUSTER" ]]; then

   # CREATE CLUSTER YAML
  cat << EOF > /development/kubernetes/cluster-create.yml
# three node (two workers) cluster config
# three node cluster with an ingress-ready control-plane node
# and extra port mappings over 80/443 and 2 workers
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: cluster-prod
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
  - containerPort: 30900
    hostPort: 30900
    protocol: TCP
  - containerPort: 32000
    hostPort: 32000
    protocol: TCP
- role: worker
- role: worker
EOF
  
else
    echo -e "${Green}/development/kubernetes/cluster-create.yml already exist${Color_Off}"
fi

if [ ! "$(kind get clusters | grep cluster-prod)" ]; then
  # CREATE KIND CLUSTER
  kind create cluster --config /development/kubernetes/cluster-create.yml

  # CREATE NGINX INGRESS
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
else
  echo -e "${Green}Kind cluster-prod already exist${Color_Off}"
fi

# INSTALL MINIKUBE
if command -v minikube > /dev/null; then
  echo -e "${Green}minikube is already installed, you may upgrade manually${Color_Off}"
else
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
  sudo dpkg -i minikube_latest_amd64.deb
  sudo minikube config set driver docker
  export CHANGE_MINIKUBE_NONE_USER=true
  export MINIKUBE_HOME=$HOME
  echo 'export CHANGE_MINIKUBE_NONE_USER=true' >> ~/.bashrc
  echo 'export MINIKUBE_HOME=/home/vagrant' >> ~/.bashrc
  sudo mv /root/.minikube $HOME/.minikube
  sudo chown -R $USER $HOME/.minikube
  sudo chgrp -R $USER $HOME/.minikube
fi

# Commands:
# minikube start --driver=docker

# INSTEAD OF USING PORT FORWARDING WE SHOULD EXPOSE THEM AS A SERVICE WITH NODEPORT OR LOADBALANCER
#https://stackoverflow.com/questions/65516359/how-to-connect-kubernetes-pod-server-on-guest-os-from-host-os
#https://github.com/kubernetes/minikube/issues/9499
#https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/