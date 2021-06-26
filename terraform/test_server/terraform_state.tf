terraform {
  backend "s3" {
    encrypt = true
    bucket  = "terraform-hadoop-openvpn"
    key     = "sandbox-hadoop/terraform.tfstate"
    region  = "us-east-1"
  }
}
