Content-Type: multipart/mixed
boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config
charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment
filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript
charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment
filename="userdata.txt"

#!/bin/bash

if [ ! -f /etc/.user-data-complete ]; then
  echo "==> Exiting since the initial script hasn't been run yet."
  exit 0
fi

echo "==> Bootstrapping setup_script for hdp..."

# dowload the sandbox or remove the stale instance and run again
function restart_stale_container() {
  if [ ! "$(docker ps -q -f name=$1)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=$1)" ]; then
      # cleanup
      docker rm $1
      docker rm $2
    fi
    # run container
    sudo bash docker-deploy-$HADOOP_SHELL_EXT.sh
  fi
}

sudo su -

HADOOP_VERSION="2.6.5"    # 3.0.1
HADOOP_SHELL_EXT="hdp265" # hdp30
LOCAL_REPO="hdp-docker-sandbox"
REMOTE_REPO="https://github.com/murshidazher/hdp-docker-sandbox.git"

cd /etc

# clone the repo only if it doesnt exist else pull the latest source
if [ -d $LOCAL_REPO/.git ]; then
  cd $LOCAL_REPO
  git pull
else
  git clone $REMOTE_REPO
fi

cd $HADOOP_VERSION
restart_stale_container "hortonworks/sandbox-hdp" "hortonworks/sandbox-proxy"

# login to sandbox hdp
# ssh root@localhost -p 2222 <<!
# hadoop
# !
docker exec -it sandbox-hdp /bin/bash
ambari-admin-password-reset <<!
adminpassword
adminpassword
!
ambari-agent restart

# install python and pip
sudo su -
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python
pip install --ignore-installed pyparsing -y
pip install mrjob==0.5.11 -y
yum install nano -y

# change to maria_dev
sudo su - maria_dev
passwd <<!
maria_devpasword
maria_devpasword
!

# change to raj_ops
sudo su - raj_ops
passwd <<!
raj_opspasword
raj_opspasword
!

# restart the ambari agent
sudo su - root
ambari-agent restart
logout
exit

# set shell integrations for ambari
sudo su -
cd /etc/$LOCAL_REPO/
cat ./shell_integration.sh | sudo tee -a ~/.bashrc # add sources to root

chmod +x ~/.bashrc
source ~/.bashrc

cat ./shell_integration.sh | sudo tee -a /etc/.bashrc # add sources to global

chmod +x /etc/.bashrc
source /etc/.bashrc

# start all ambari services
cd /etc/$LOCAL_REPO/$HADOOP_VERSION
startall # start all services

--//
