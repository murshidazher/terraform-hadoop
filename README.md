# [terraform-hdp](https://github.com/murshidazher/terraform-hdp)

> A terraform setup for setting up hdp's big data analytics server instance in aws. 🔥🔥🔥

## Table of Contents

- [terraform-hdp](#terraform-hdp)
  - [Table of Contents](#table-of-contents)
  - [📚 Installing / Getting started](#-installing--getting-started)
    - [⚙️ Configure](#️-configure)
    - [🏁 Initialize](#-initialize)
    - [📦 Workspaces](#-workspaces)
    - [💥 Provisioning](#-provisioning)
  - [🚀 Usage](#-usage)
  - [Basic commands](#basic-commands)
    - [Docker troubleshooting](#docker-troubleshooting)
      - [Sandbox Bash](#sandbox-bash)
    - [Setup Python](#setup-python)
      - [If python 3.6 needed](#if-python-36-needed)
  - [Security](#security)
    - [Add Hosts Ip to Mac](#add-hosts-ip-to-mac)
  - [Destroy](#destroy)
  - [References](#references)
  - [License](#license)

## 📚 Installing / Getting started

> ⚠️ Before running the scripts, create a remote s3 bucket to store the terraform state with the name of `javahome-tf-1212` or any-other name. `AWS_PROFILE=<username>` is the local aws profile credentials you've configured if you don't use global credentials.

### ⚙️ Configure

To configure the public ip address, replace the `HostIp` environment variable found in `env > dev.tfvars | prod.tfvars`,

```sh
> curl https://checkip.amazonaws.com
```

### 🏁 Initialize

Initialize terraform

```sh
> cd terraform
> terraform init
```

Create AWS keypair that will be used to login into AWS instance,

```sh
> cd terraform/scripts # generate keys inside scripts
> aws ec2 create-key-pair --key-name hwsndbx --query 'KeyMaterial' --output text > hwsndbx.pem
```

### 📦 Workspaces

> 💡 Either configure the global `aws` profile or append each terraform command with `AWS_PROFILE=<username>`

```sh
> terraform workspace list # created at terraform init
```

To create two new workspaces,

```sh
> terraform workspace new dev
> terraform workspace new prod
```

If we need to provision the resources in the dev workspaces we need to first select the `dev` workspace.

```sh
> terraform workspace select dev
> terraform apply
```

### 💥 Provisioning

Apply terraform script,

```sh
> terraform workspace select dev
> terraform plan -var-file=./env/dev.tfvars
> terraform apply -auto-approve -var-file=./env/dev.tfvars 
```

## 🚀 Usage

So to connect using ssh we need a permission of `400` but by default it will be `644`,

```sh
> ls -la # to see the permission of the pem file
> chmod 400 ./scripts/hwsndbx.pem
> ssh -i ./scripts/hwsndbx.pem ec2-user@<output_instance_ip>
```

Install `HDP` through docker,

```sh
> docker info
> cd ../../hdp-docker-sandbox/HDP_2.6.5
> sudo bash docker-deploy-hdp265.sh
> docker ps
> docker ps -a
```

To restart the containers,

```sh
> cd hdp-docker-sandbox
> sudo bash restart_docker.sh
```

- After it finishes, access Ambari through `http://your-ec2-public-ip:8080/`.
- The default Ambari credential is `raj_ops`:`raj_ops` and `maria_dev`: `maria_dev` . The default AmbariShell login credential is `root`:`hadoop`.

## Basic commands

### Docker troubleshooting

```sh
> sudo docker images
> sudo service docker restart
> sudo service docker status
```

#### Sandbox Bash

> Read [cloudera hdp sandbox](https://www.cloudera.com/tutorials/learning-the-ropes-of-the-hdp-sandbox.html) and [apache ambari shell commands](https://cwiki.apache.org/confluence/display/AMBARI/Ambari+Shell) for more information.

To peek into the docker sandbox,

```sh
> docker exec -it <docker-sandbox-image-id> /bin/bash
> ssh root@localhost -p 2222 # or you can use this with password hadoop
> ambari-agent status
> ambari-agent start # if stopped start
> ambari-server restart
```

### Setup Python

HortonWorks doesnt come with lot of resources out-of-the-box to work with python,

```sh
> sudo su -
> yum install python-pip -y
> pip install google-api-python-client==1.6.4
# > curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python
# > pip install --ignore-installed pyparsing
> pip install mrjob==0.5.11 #MRJob
> yum install nano -y
```

Example data files and scripts to play with,

```sh
> sudo su - maria_dev
> wget http://media.sundog-soft.com/hadoop/ml-100k/u.data
> wget http://media.sundog-soft.com/hadoop/RatingsBreakdown.py
> hadoop fs -copyFromLocal u.data /user/maria_dev/ml-100k/u.data
> python RatingsBreakdown.p u.data
> python RatingsBreakdown.py -r hadoop --hadoop-streaming-jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-streaming.jar u.data #mrjob manually copies the file to hdfs temp location and executes it
> hostname -I | awk '{print $1}' # get the ip
> python RatingsBreakdown.py -r hadoop --hadoop-streaming-jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-streaming.jar hdfs://172.18.0.2:8020/user/maria_dev/ml-100k/u.data 
> python RatingsBreakdown.py -r hadoop --hadoop-streaming-jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-streaming.jar hdfs:///user/maria_dev/ml-100k/u.data 
```

#### If python 3.6 needed

```sh
> yum install python36
> sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
> sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
> sudo update-alternatives  --set python /usr/bin/python3.6

```

Or just change the symbolic link,

```sh
> cd /usr/bin
> ls -lrth python*
> unlink python
> ln -s /usr/bin/python3.6 python
> python --version
```

## Security

Change the `ambari` password once you create the instance,

```sh
> docker exec -it sandbox-hdp /bin/bash
> ambari-admin-password-reset
> ambari-agent restart
```

### Add Hosts Ip to Mac

> 💡 `C:\Windows\System32\drivers\etc\hosts` on Windows or `/etc/hosts `on a MacOSX

In case you want a CNAME, you can add this line to your hosts file. Add `hostip` to the mac to use as a domain name locally, to save and exit out of nano editor `ctrl + o` > `enter` > `ctrl + x`

```sh
> sudo nano /etc/hosts # add the ip and map to a host 
> sudo killall -HUP mDNSResponder # flush DNS cache
```

```txt
127.0.0.1 sandbox-hdp.hortonworks.com
```

## Destroy

```sh
> terraform destroy -auto-approve
```

## References

- Installation guide for [single cluster](https://ruslanmv.com/blog/Cloudera-HDP-Sanbox-on-AWS).
- Installation guide for [multiple cluster nodes](https://docs.google.com/document/d/1jsf8iU_mvcbhSqoh-VXGDxmHvpYcvsdn9rxbA0nj624/edit).
- To increase the [storage instance type](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#ebs-ephemeral-and-root-block-devices).
- [Maven and Java setup](https://linuxize.com/post/how-to-install-apache-maven-on-centos-7/)
- [DDP + Ambari 2.7.5 CentOS7](https://github.com/steven-matison/dfhz_ddp_mpack).
- [Starting and stopping ambari services using CURL command](https://www.zylk.net/en/web-2-0/blog/-/blogs/starting-services-via-ambari-rest-api)
- [Look into terraform local-exec for stopping and starting server instances](https://stackoverflow.com/questions/57158310/how-to-restart-ec2-instance-using-terraform-without-destroying-them)
- [Ambari REST Api to restart all services](https://community.cloudera.com/t5/Support-Questions/Ambari-REST-API-to-restart-all-services/td-p/172172)

## License

[MIT](./LICENSE) © Murshid Azher.
