# Vagrant VMs

You can clone this repo and run the following command to bring up a VM inside DevOps-VM-SingleNode: _vagrant up --provision_

# How to modify settings.yaml

1. devops_ip: It defines the VM NAT IP
2. master_vm: It defines the VM hostname
3. cPU: It defines the amount of vCPU's assigned in Virtual Box for the VM
4. memory: It defines the amount of Memory assigned in Virtual Box for the VM
5. box: You can choose either bento/ubuntu-22.04 or debian/bookworm64
6. dev_disk: By default, it will add a second disk to the VM of 10GB in /development so you can define here the size

# How to modify Vagrant File

1. Comment out the shell scripts that you want to ski

# Scripts included

1. development.sh: This script partition and mount the second disk to the VM
2. common.sh: This script add the UI to the VM's otherwise they will be headless, however, many of the software requires a UI.
3. visualcode.sh: Install Visual Code to the VM
4. terraform.sh: Install Terraform to the VM
5. aws-cli.sh: Install aws-cli to the VM
6. githubdesktop.sh: Install Github Desktop to the VM
7. docker.sh: Install Docker to the VM
8. tweaks.sh: Adds some tweaks to Gnome, you may need to run the commands manually after the first boot.
9. jenkins.sh: Install Jenkins to the VM, it depends on docker.sh
10. kubernetes.sh: Install Kind and Minikube for Kubernetes, it depends on docker.sh
11. prometheus-operator.sh: Install prometheus-operator helm chart, it depends on kubernetes.sh
12. prometheus-standalone.sh: Install prometheus helm chart, this is required only if you don't want to use prometheus-operator, it depends on kubernetes.sh
13. grafana.sh: Install grafana, this is required only if you don't want to use prometheus-operator, it depends on kubernetes.sh
14. openlens.sh: Install Open Lens to manage the Kubernetes Cluster, it depends on kubernetes.sh

# Additional Info

1. Passwords of each application (Jenkins and Grafana) can be found under /development
2. Cluster configuration for kind can be found also under /development

# Access to Applications

1. Jenkins is exposed through port 8080 to your host vm so you can access it through: http://10.10.0.10:8080/
2. Prometheus is exposed through port 30900 to your host vm so you can access it through: http://10.10.0.10:30900/
3. Grafana is exposed through port 30000 to your host vm so you can access it through: http://10.10.0.10:30000/

# Known issues:

1. Debian VM has not IDE Controller, you may need to shutdown the VM, add the IDE Controller Manually so you can add the VBoxGuestAdditions.iso
