# install hadoop sandbox script

# login to sandbox hdp
# ssh root@localhost -p 2222 <<!
# hadoop
# !
docker exec -it sandbox-hdp /bin/bash <<EOF

    # reset ambari password
    ambari-admin-password-reset <<!
    adminpassword
    adminpassword
    !
    ambari-agent restart

    # install python and pip
    sudo su -
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python
    pip install --ignore-installed pyparsing
    pip install mrjob==0.5.11
    yum install nano -y

    # restart the ambari agent
    sudo su - root
    ambari-agent restart
    exit
    exit
EOF

echo "Example remote move script"
