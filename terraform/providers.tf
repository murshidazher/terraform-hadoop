# Create key using awscli
# aws ec2 create-key-pair --key-name hw-sndbx --query 'KeyMaterial' --output text > hw-sndbx.pem

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "javahome-tf-1212"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
