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
    - [Add Hosts Ip to Mac](#add-hosts-ip-to-mac)
    - [MySQL](#mysql)
  - [💣 Destroy](#-destroy)
  - [References](#references)
  - [License](#license)

## 📚 Installing / Getting started

> ⚠️ Before running the scripts, create a remote s3 bucket to store the terraform state with the name of `javahome-tf-1212` or any-other name. `AWS_PROFILE=<username>` is the local aws profile credentials you've configured if you don't use global credentials.

### ⚙️ Configure

To configure the public ip address, replace the `HostIp` environment variable found in `env > dev.tfvars | prod.tfvars`,

```sh
> dig +short myip.opendns.com @resolver1.opendns.com
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
> docker exec -it 9d5c260ff545 /bin/bash
> ambari-agent status
> ambari-agent start # if stopped start
> ambari-server restart
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

### MySQL

- Username `root` and password `root`

## 💣 Destroy

```sh
> terraform destroy -auto-approve
```

## References

- Installation guide for [single cluster](https://ruslanmv.com/blog/Cloudera-HDP-Sanbox-on-AWS).
- Installation guide for [multiple cluster nodes](https://docs.google.com/document/d/1jsf8iU_mvcbhSqoh-VXGDxmHvpYcvsdn9rxbA0nj624/edit).
- To increase the [storage instance type](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#ebs-ephemeral-and-root-block-devices).
- [Maven and Java setup](https://linuxize.com/post/how-to-install-apache-maven-on-centos-7/)
- [DDP + Ambari 2.7.5 CentOS7](https://github.com/steven-matison/dfhz_ddp_mpack).

## License

[MIT](./LICENSE) © Murshid Azher.
