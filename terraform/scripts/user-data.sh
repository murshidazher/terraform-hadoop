#!/bin/bash

sudo yum update -y
sudo yum install -y git
git clone https://github.com/ruslanmv/HDP-Sandbox-AWS.git
cd HDP-Sandbox-AWS
bash install_docker.sh
# sudo curl -sSL https://get.docker.com/ | sh
# sudo apt-get update && sudo apt-get upgrade
## Read this for more info on [docker as service on restart](https://stackoverflow.com/questions/47948703/ensuring-docker-container-will-start-automatically-when-host-starts)
# sudo systemctl enable docker
# sudo apt-get install nginx
