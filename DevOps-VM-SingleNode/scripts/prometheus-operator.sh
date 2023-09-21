#! /bin/bash
#title        :prometheus.sh
#description  :This script install Prometheus if it doesn't exist
#author       :Fernando Brenes
#date         :2023-09-11
#version      :1.0.0
#notes        :This script has kubernetes as a dependency
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
Begin Prometheus\n
***********************************************${Color_Off}"
# INSTALL PROMETHEUS
# BEFORE INSTALLING WE NEED TO MAKE SURE ALL PODS IN kube-system are ready
#sleep 60
kubectl wait --for=condition=Ready pods --all -n kube-system --timeout=120s

if [[ "`kubectl get pods --namespace default -l "app=kube-prometheus-stack-operator,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}"`" ]]; then
	echo -e "${Green}Prometheus pods already exist${Color_Off}"
else
    # BEFORE INSTALLING WE NEED TO MAKE SURE ALL PODS IN kube-system are ready
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 
	  helm install prometheus prometheus-community/kube-prometheus-stack
    export POD_PROMETHEUS=$(kubectl get pods --namespace default -l "app=kube-prometheus-stack-operator,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
    kubectl wait pod/$POD_PROMETHEUS --for=condition=Ready --timeout=300s
    #kubectl --namespace default port-forward $POD_PROMETHEUS 9090 &
    cat << EOF > /development/kubernetes/prometheus-service.yml
apiVersion: v1
kind: Service
metadata:
  name: prometheus-service
  namespace: default
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port:   '3000'
spec:
  selector:
    app.kubernetes.io/name: prometheus
  type: NodePort
  ports:
    - port: 9090
      targetPort: 9090
      nodePort: 30900
EOF
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
    kubectl create -f /development/kubernetes/prometheus-service.yml
fi


