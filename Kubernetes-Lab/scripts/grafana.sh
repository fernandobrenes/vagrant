#! /bin/bash
#title        :grafana.sh
#description  :This script install Grafana if it doesn't exist
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
Begin Grafana\n
***********************************************${Color_Off}"

# INSTALL GRAFANA
# BEFORE INSTALLING WE NEED TO MAKE SURE ALL PODS IN kube-system are ready
kubectl wait --for=condition=Ready pods --all -n kube-system --timeout=120s

if [[ "`kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}"`" ]]; then
	echo -e "${Green}Grafana pods already exist${Color_Off}"
else
    helm repo add grafana https://grafana.github.io/helm-charts
    helm install grafana grafana/grafana
    kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode | sudo tee /development/kubernetes/grafana-pass.txt
    export POD_GRAFANA=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
    kubectl wait pod/$POD_GRAFANA --for=condition=Ready --timeout=300s
    #kubectl --namespace default port-forward $POD_GRAFANA 3000 &
    # EXPOSE GRANAFA TO YOUR HOST MACHINE USING THE HOST ONLY NETWORK
cat << EOF > /development/kubernetes/grafana-service.yml
apiVersion: v1
kind: Service
metadata:
  name: grafana-service
  namespace: default
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port:   '3000'
spec:
  selector: 
    app.kubernetes.io/name: grafana
  type: NodePort  
  ports:
    - port: 3000
      targetPort: 3000 
      nodePort: 30000
EOF
    kubectl create -f /development/kubernetes/grafana-service.yml
fi