terraform {
  backend "s3" {
    encrypt = true
    bucket  = "terraform-hadoop-openvpn"
    key     = "sandbox-openvpn/terraform.tfstate"
    region  = "us-east-1"
  }
}
