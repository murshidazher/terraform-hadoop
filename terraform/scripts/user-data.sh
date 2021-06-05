#!/bin/bash

sudo yum update -y
sudo yum install -y git
git clone https://github.com/ruslanmv/HDP-Sandbox-AWS.git
cd HDP-Sandbox-AWS
bash install_docker.sh
