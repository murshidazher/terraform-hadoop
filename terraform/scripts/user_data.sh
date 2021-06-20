#!/bin/bash

set -eux -o

sudo yum update -y
sudo yum install -y git
sudo yum install -y docker

## start docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# write as docker setup complete
sudo touch /etc/.user-data-complete

# restart
sudo shutdown -r now
# reboot
