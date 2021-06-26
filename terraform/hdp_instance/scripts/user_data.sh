#!/bin/bash

set -eux -o

sudo yum update -y
sudo yum install -y git
sudo yum install -y docker

## start docker
sudo service docker start
sudo usermod -a -G docker ec2-user

HADOOP_VERSION="2.6.5"    # 3.0.1
HADOOP_SHELL_EXT="hdp265" # hdp30
LOCAL_REPO="hdp-docker-sandbox"
REMOTE_REPO="https://github.com/murshidazher/hdp-docker-sandbox.git"

# dowload the sandbox or remove the stale instance and run again
function restart_stale_container() {
  if [ ! "$(docker ps -q -f name=$1)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=$1)" ]; then
      # cleanup
      docker rm "$1"
      docker rm "$2"
    fi
    # run container
    sudo bash docker-deploy-"$HADOOP_SHELL_EXT".sh
  fi
}

cd /tmp || exit

# clone the repo only if it doesnt exist else pull the latest source
if [ -d $LOCAL_REPO/.git ]; then
  cd $LOCAL_REPO || exit
  git pull
else
  git clone $REMOTE_REPO
fi

cd $HADOOP_VERSION || exit
restart_stale_container "hortonworks/sandbox-hdp" "hortonworks/sandbox-proxy"
