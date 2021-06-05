# [terraform-hadoop](https://github.com/murshidazher/terraform-hadoop)

> A hadoop terraform setup IaC

## Table of Contents

- [terraform-hadoop](#terraform-hadoop)
  - [Table of Contents](#table-of-contents)
  - [Up and Running](#up-and-running)
  - [License](#license)

## Up and Running

To get the public ip address and replace it in the variables folder,

```sh
> dig +short myip.opendns.com @resolver1.opendns.com
```

Initialize terraform

```sh
> cd terraform
> terraform init
```

Create AWS keypair that will be used to login into AWS instance,

```sh
> AWS_PROFILE=jam aws ec2 create-key-pair --key-name hw-sndbx --query 'KeyMaterial' --output text > hw-sndbx.pem
```

Apply terraform script

```sh
> terraform plan 
> terraform apply
```

So to connect using ssh we need a permission of `400` but by default it will be `644`,

```sh
> ls -la # to see the permission of the pem file
> chmod 400 hw-sndbx.pem
> ssh -i hw-sndbx.pem ec2-user@<output_instance_ip>
```

## License
