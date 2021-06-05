# [terraform-hadoop](https://github.com/murshidazher/terraform-hadoop)

> A hadoop terraform setup for setting up big data analytics server instance. 🔥🔥🔥

- Installation guide for [single cluster](https://ruslanmv.com/blog/Cloudera-HDP-Sanbox-on-AWS) 
- Installation guide can be found [here](https://docs.google.com/document/d/1jsf8iU_mvcbhSqoh-VXGDxmHvpYcvsdn9rxbA0nj624/edit) for multiple cluster nodes.

## Table of Contents

- [terraform-hadoop](#terraform-hadoop)
  - [Table of Contents](#table-of-contents)
  - [📚 Installing / Getting started](#-installing--getting-started)
    - [⚙️ Configure](#️-configure)
    - [🏁 Initialize](#-initialize)
    - [📦 Workspaces](#-workspaces)
    - [💥 Provisioning](#-provisioning)
  - [🚀 Usage](#-usage)
  - [💣 Destroy](#-destroy)
  - [License](#license)

## 📚 Installing / Getting started

> ⚠️ Before running the scripts, create a remote s3 bucket to store the terraform state with the name of `javahome-tf-1212`. `AWS_PROFILE=<username>` is the local aws profile credentials you've configured if you don't use global credentials.

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
> ssh -i ./scripts/hwsndbx.pem centos@<output_instance_ip>
```

## 💣 Destroy

```sh
> terraform destroy
```

## License

[MIT](./LICENSE) © Murshid Azher.
