#!/bin/bash

if [ ! -f /tmp/.user-data-complete ]; then
  echo "==> Exiting since the initial script hasn't been run yet."
  exit 0
fi

echo "==> Bootstrapping setup_script for hdp..."

sudo yum update -y
sudo yum install httpd -y

sudo systemctl start httpd
sudo systemctl enable httpd

echo "<h1> Java Home App</h1>" >/var/www/html/index.html

HADOOP_VERSION="2.6.5"    # 3.0.1
HADOOP_SHELL_EXT="hdp265" # hdp30
LOCAL_REPO="hdp-docker-sandbox"
REMOTE_REPO="https://github.com/murshidazher/hdp-docker-sandbox.git"

cd /tmp/scripts

# clone the repo only if it doesnt exist else pull the latest source
if [ -d $LOCAL_REPO/.git ]; then
  cd $LOCAL_REPO
  git pull
else
  git clone $REMOTE_REPO
fi

exit 0
