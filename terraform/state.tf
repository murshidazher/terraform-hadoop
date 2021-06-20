terraform {
  backend "s3" {
    encrypt = true
    bucket  = "javahome-tf-1212"
    key     = "sandbox-hdp/terraform.tfstate"
    region  = "us-east-1"
  }
}
