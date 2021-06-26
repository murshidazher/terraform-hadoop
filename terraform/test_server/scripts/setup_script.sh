#!/bin/bash

# am example file move

if [ ! -f /tmp/.user-data-complete ]; then
  echo "==> Exiting since the initial script hasn't been run yet."
  exit 0
fi

echo "==> Bootstrapping setup_script for hdp..."

HADOOP_VERSION="2.6.5"    # 3.0.1
HADOOP_SHELL_EXT="hdp265" # hdp30
LOCAL_REPO="hdp-docker-sandbox"
REMOTE_REPO="https://github.com/murshidazher/hdp-docker-sandbox.git"

mkdir /tmp/scripts
cd /tmp/scripts

# clone the repo only if it doesnt exist else pull the latest source
if [ -d $LOCAL_REPO/.git ]; then
  cd $LOCAL_REPO
  git pull
else
  git clone $REMOTE_REPO
fi

exit 0
