# Create key using awscli
# aws ec2 create-key-pair --key-name hw-sndbx --query 'KeyMaterial' --output text > hw-sndbx.pem

provider "aws" {
  region = var.region
}
