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
# docker exec -it sandbox-hdp /bin/bash
ssh root@localhost -p 2222 <<!
hadoop
!
ambari-admin-password-reset <<!
adminpasword
adminpasword
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

# set AMBARI_ADMIN_USER="admin", AMBARI_ADMIN_PASSWORD, AMBARI_HOST="localhost", CLUSTER_NAME
# set these as global variables
export SERVICE=ZEPPELIN
export PASSWORD=admin
export AMBARI_HOST=localhost

# detect name of cluster
# sent it to the bashrc profile to be detected
output=$(curl -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -H 'X-Requested-By: ambari' http://$AMBARI_HOST:8080/api/v1/clusters)

CLUSTER_NAME=$(echo $output | sed -n 's/.*"cluster_name" : "\([^\"]*\)".*/\1/p')

echo $CLUSTER_NAME

# start all ambari services
# https://github.com/crazyadmins/useful-scripts/blob/master/ambari/ambari-admin.sh
cd /etc/$LOCAL_REPO/$HADOOP_VERSION

--//
