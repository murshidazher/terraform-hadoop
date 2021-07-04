# [terraform-hdp](https://github.com/murshidazher/terraform-hdp)

> A terraform setup for setting up hdp's big data analytics server instance in aws. 🔥🔥🔥

## Table of Contents

- [terraform-hdp](#terraform-hdp)
  - [Table of Contents](#table-of-contents)
  - [Installing / Getting started](#installing--getting-started)
    - [Configure](#configure)
    - [Initialize](#initialize)
    - [Optional: Workspaces](#optional-workspaces)
    - [Provisioning](#provisioning)
  - [OpenVPN - Bastion Host](#openvpn---bastion-host)
    - [Setup OpenVPN](#setup-openvpn)
    - [Using domain](#using-domain)
    - [Optional: Add SSL Cert for `https`](#optional-add-ssl-cert-for-https)
  - [HDP Instance](#hdp-instance)
  - [Usage](#usage)
  - [Basic commands](#basic-commands)
    - [Docker troubleshooting](#docker-troubleshooting)
      - [Sandbox Bash](#sandbox-bash)
    - [Setup Python](#setup-python)
      - [If python 3.6 needed](#if-python-36-needed)
  - [Security](#security)
    - [Add Hosts Ip to Mac](#add-hosts-ip-to-mac)
  - [Pausing and Resuming Instances](#pausing-and-resuming-instances)
  - [Destroy](#destroy)
  - [References](#references)
  - [License](#license)

## Installing / Getting started

> ⚠️ Before running the scripts, create a remote s3 bucket to store the terraform state.

- By default, the name of the remote state bucket is `terraform-hadoop`.
- If you want to create your own bucket with any-other name, ensure that you replace the default remote bucket name mentioned in `state.tf`.

### Configure

To configure the public ip address, replace the `HostIp` environment variable found in `env > dev.tfvars | prod.tfvars`,

```sh
> curl https://checkip.amazonaws.com
```

### Initialize

> :bulb:If you don't want to utilize global credentials, add `AWS PROFILE=username>` to each terraform and aws command given below.

Initialize terraform

```sh
> cd terraform/private_vpc
> terraform init
```

Create AWS keypair that will be used to login into AWS instance, same KeyPair would be used for initializing the other instances too

```sh
> cd terraform/scripts # generate keys inside scripts
> aws ec2 create-key-pair --key-name hwsndbx --query 'KeyMaterial' --output text > hwsndbx.pem
```

### Optional: Workspaces

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

### Provisioning

Apply terraform script,

```sh
> terraform plan
> terraform apply -auto-approve
```

Optional: Apply terraform script with environment variables,

```sh
> terraform plan -var-file=./env/dev.tfvars
> terraform apply -auto-approve -var-file=./env/dev.tfvars
```

## OpenVPN - Bastion Host

Since we need a proper way to access our server and we cant tie the server down to our local dynamic ip which changes everytime, we create a new ec2 instance with openvpn to act as the bastion host.

> For OpenVPN setup refer to this [video](https://www.youtube.com/watch?v=9Lk-ceYpSfU&list=PLH1ul2iNXl7uLKyLj7BaTQJyfhj7Ja9cU&index=7).

Change the `openvpn_ami_id` based on your specified region,

```sh
> aws --region=us-east-1 ec2 describe-images --owner=aws-marketplace --filters 'Name=name,Values=OpenVPN Access Server 2.7.5*'
```

```sh
> cd terraform/bastion_host_openvpn
> terraform init
> terraform plan
> terraform apply
```

### Setup OpenVPN

> Read through this for [more setup](https://aws.amazon.com/blogs/awsmarketplace/setting-up-openvpn-access-server-in-amazon-vpc/).

Connect to the OpenVPN instance using the assigned elastic ip,

```sh
> ssh -i ./scripts/hwsndbx.pem openvpnas@<elasticip>
```

Use all settings as default. And change the password

```sh
> sudo passwd openvpn
```

Then go to the OpenVPN WebUI `https://<elastic-ip>:943`. Use username as `openvpn` and password configured in the terminal above.

- In Configuration > VPN Settings > Routing > Enable `Should client Internet traffic be routed through the VPN?`
- With this configuration, the VPN client IP address is translated before being presented to resources inside the VPC. That means the client’s original IP address is remapped to one belonging to the VPC IP address space.

### Using domain

We can use the domain by adding the `nameserver` generated by terraform apply output to the domain DNS.

### Optional: Add SSL Cert for `https`

> Read more on adding [SSL Cert](https://www.stephengreer.me/setting-up-a-vpn-access-server-on-aws-using-terraform).

Right now you should be access you VPN's admin GUI by going to [https://<elastic-ip>/admin](https://<elastic-ip>/admin). However, your browser will show a warning as the SSL cert is not valid. You can bypass this warning to access the admin, but we should setup a valid SSL cert.

- Use [ZeroSSL](https://zerossl.com/) to obtain your cetificate for free.

Walk through the [wizard](https://zerossl.com/free-ssl/#crt) to create a new Let's Encrypt certificate. You will be required to verify your domain as part of this process.

Copy the Certificate, CA Bundle and Private Key to files.

Login to your VPN access server GUI using the user `openvpn` and created on the server. Navigate to Settings > Web Server. From there, upload the Certificate, CA Bundle and Private Key files. Click validate and save if there are no errors.

## HDP Instance

Next, we will provision HDP as a spot instance if you need it as a readily-available instance change directory to ``.

```sh
> cd terraform/hdp_instance
> terraform init
> terraform plan
> terraform apply
```

## Usage

So to connect using ssh we need a permission of `400` but by default it will be `644`,

```sh
> ls -la # to see the permission of the pem file
> chmod 400 ./scripts/hwsndbx.pem # same key for all
> ssh -i ./scripts/hwsndbx.pem ec2-user@<output_instance_ip>
```

Install `HDP` through docker,

```sh
> docker info
> cd /tmp/hdp-docker-sandbox/HDP_2.6.5
> sudo bash docker-deploy-hdp265.sh
> docker ps
> docker ps -a
```

To restart the containers,

```sh
> cd /tmp/hdp-docker-sandbox
> sudo bash restart_docker.sh
```

- After it finishes, access Ambari through `http://elastic-public-ip:8080/`.
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
> command -v pip # see pip is installed
> command -v pip3 # see pip3 installed
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

## Pausing and Resuming Instances

> ⚠️ Keep in mind, though there aren't any changes for a stopped instance, you may still incur charges for `EBS` storage and `ElasticIP` associated to the instances.

Once created and you want to `stop` instances just execute,

```sh
> cd /tmp/hdp-docker-sandbox
> pause_docker.sh # pause the instance
> cd hdp_instance
> terraform output # get the id from output for hdp instance
> aws ec2 stop-instances --instance-ids <instance_id> --profile edutf
> bastion_host_openvpn
> terraform output # get the id from output for openvpn instance
> aws ec2 stop-instances --instance-ids <instance_id> --profile edutf
```

Once created and you want later to `reboot` after a stop,

```sh
> bastion_host_openvpn
> terraform output # get the id from output for openvpn instance
> aws ec2 start-instances --instance-ids <instance_id> --profile edutf
> cd hdp_instance
> terraform output # get the id from output for hdp instance
> aws ec2 start-instances --instance-ids <instance_id> --profile edutf
> cd terraform/hdp_instance
> ssh -i ./scripts/hwsndbx.pem ec2-user@<instance_ip>
> cd /tmp/hdp-docker-sandbox
> resume_docker.sh # resume the instance
```

## Destroy

To destroy the terraform instance,

```sh
> terraform destroy -auto-approve
```

## References

- Installation guide for [a single cluster HDP installation](https://ruslanmv.com/blog/Cloudera-HDP-Sanbox-on-AWS).
- Installation guide for [multiple cluster nodes](https://docs.google.com/document/d/1jsf8iU_mvcbhSqoh-VXGDxmHvpYcvsdn9rxbA0nj624/edit).
- To increase the [storage instance type](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#ebs-ephemeral-and-root-block-devices).
- [Maven and Java setup](https://linuxize.com/post/how-to-install-apache-maven-on-centos-7/)
- [DDP + Ambari 2.7.5 CentOS7](https://github.com/steven-matison/dfhz_ddp_mpack).
- [Starting and stopping ambari services using CURL command](https://www.zylk.net/en/web-2-0/blog/-/blogs/starting-services-via-ambari-rest-api)
- [Look into terraform local-exec for stopping and starting server instances](https://stackoverflow.com/questions/57158310/how-to-restart-ec2-instance-using-terraform-without-destroying-them)
- [Ambari REST Api to restart all services](https://community.cloudera.com/t5/Support-Questions/Ambari-REST-API-to-restart-all-services/td-p/172172)
- [Ambari REST Api commands](https://community.cloudera.com/t5/Community-Articles/Ambari-Admin-Utility-Part-1/ta-p/246258)
- [Solve PigTez Failure on Ambari 2.6.5](https://community.cloudera.com/t5/Support-Questions/Pig-view-fail-with-tez-execution/td-p/201377)

## License

[MIT](./LICENSE) © Murshid Azher.
