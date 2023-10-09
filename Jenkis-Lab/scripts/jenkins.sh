#! /bin/bash
#title        :jenkins.sh
#description  :This script install Jenkins if it doesn't exist
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
Begin Jenkins\n
***********************************************${Color_Off}"

# SAVE JENKINS CREDENTIALS IN DEVELOPMENT FOLDER
#sudo -s -u vagrant
$JENKINSPATH=/development/jenkins
if [[ ! -d "$JENKINSPATH" ]]; then
    sudo mkdir -p $JENKINSPATH
fi
sudo chmod -R 2775 /development/jenkins

# INSTALL UI BASED ON OS 
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ $OS == '"Ubuntu"' ]]; then
    echo -e "${Green}Ubuntu OS Detected, installing Jenkins${Color_Off}"
    
    # INSTALL JENKINS   
    if [ ! "$(docker network ls | grep jenkins)" ]; then
        echo "Creating jenkins network ..."
        docker network create jenkins
    else
        echo -e "${Green}jenkins network already exist${Color_Off}"
    fi

    if [ $( docker container ls | grep jenkins-docker | wc -l ) -gt 0 ]; then
        echo "jenkins-docker exists"
    else
        docker run \
        --name jenkins-docker \
        --rm \
        --detach \
        --privileged \
        --network jenkins \
        --network-alias docker \
        --env DOCKER_TLS_CERTDIR=/certs \
        --volume jenkins-docker-certs:/certs/client \
        --volume jenkins-data:/var/jenkins_home \
        --publish 2376:2376 \
        docker:dind \
        --storage-driver overlay2
    fi

    FILE=/development/jenkins/Dockerfile
    if [[ ! -f "$FILE" ]]; then

        cat << EOF > /development/jenkins/Dockerfile
FROM jenkins/jenkins:2.414.1-jdk17
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN mkdir -m 0755 -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
EOF
        if [ $( docker container ls | grep jenkins-blueocean | wc -l ) -gt 0 ]; then
            echo "jenkins-blueocean exists"
        else
            cd /development/jenkins
            docker build -t myjenkins-blueocean:2.414.1-1 .

            docker run \
            --name jenkins-blueocean \
            --restart=on-failure \
            --detach \
            --network jenkins \
            --env DOCKER_HOST=tcp://docker:2376 \
            --env DOCKER_CERT_PATH=/certs/client \
            --env DOCKER_TLS_VERIFY=1 \
            --publish 8080:8080 \
            --publish 50000:50000 \
            --volume jenkins-data:/var/jenkins_home \
            --volume jenkins-docker-certs:/certs/client:ro \
            myjenkins-blueocean:2.414.1-1
        fi
        
        until [ "`docker inspect -f {{.State.Status}} jenkins-blueocean`" == "running" ]; do sleep 1; done
        # sleep 90 volver a poner ese sleep si falla
        until docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword; do sleep 1; done
        docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword > /development/jenkins/jenkins_passwd.txt
    else
        echo -e "${Green}/development/jenkins/Dockerfile already exist${Color_Off}"
    fi
    

elif [[ $OS == '"Debian GNU/Linux"' ]]; then
    echo -e "${Green}Debian OS Detected, installing Jenkins${Color_Off}"

    # INSTALL JENKINS   
    if [ ! "$(docker network ls | grep jenkins)" ]; then
        echo "Creating jenkins network ..."
        docker network create jenkins
    else
        echo -e "${Green}jenkins network already exist${Color_Off}"
    fi

    if [ $( docker container -ls | grep jenkins-docker | wc -l ) -gt 0 ]; then
        echo "jenkins-docker exists"
    else
        docker run \
        --name jenkins-docker \
        --rm \
        --detach \
        --privileged \
        --network jenkins \
        --network-alias docker \
        --env DOCKER_TLS_CERTDIR=/certs \
        --volume jenkins-docker-certs:/certs/client \
        --volume jenkins-data:/var/jenkins_home \
        --publish 2376:2376 \
        docker:dind \
        --storage-driver overlay2
    fi

    FILE=/development/jenkins/Dockerfile
    if [[ ! -f "$FILE" ]]; then
        cat << EOF > /development/jenkins/Dockerfile
        FROM jenkins/jenkins:2.414.1-jdk17
        USER root
        RUN apt-get update && apt-get install -y lsb-release
        RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
        https://download.docker.com/linux/debian/gpg
        RUN echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
        https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
        RUN apt-get update && apt-get install -y docker-ce-cli
        USER jenkins
        RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
EOF
        if [ $( docker container -ls | grep jenkins-blueocean | wc -l ) -gt 0 ]; then
            echo "jenkins-blueocean exists"
        else
            cd /development/jenkins
            docker build -t myjenkins-blueocean:2.414.1-1 .

            docker run \
            --name jenkins-blueocean \
            --restart=on-failure \
            --detach \
            --network jenkins \
            --env DOCKER_HOST=tcp://docker:2376 \
            --env DOCKER_CERT_PATH=/certs/client \
            --env DOCKER_TLS_VERIFY=1 \
            --publish 8080:8080 \
            --publish 50000:50000 \
            --volume jenkins-data:/var/jenkins_home \
            --volume jenkins-docker-certs:/certs/client:ro \
            myjenkins-blueocean:2.414.1-1
        fi

        until [ "`docker inspect -f {{.State.Status}} jenkins-blueocean`" == "running" ]; do sleep 1; done
        #sleep 90
        #docker exec jenkins-blueocean ls /var/jenkins_home/secrets/
        #docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword > /development/jenkins/jenkins_passwd.txt
        until docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword; do sleep 1; done
        docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword > /development/jenkins/jenkins_passwd.txt
    else
        echo -e "${Green}/development/jenkins/Dockerfile already exist${Color_Off}"
    fi
else
    echo -e "${Red}Uknown OS${Color_Off}"
    exit 1
fi