terraform {
  backend "s3" {
    encrypt = true
    bucket  = "terraform-hadoop-openvpn"
    key     = "sandbox-hadoop-instance/terraform.tfstate"
    region  = "us-east-1"
  }
}
