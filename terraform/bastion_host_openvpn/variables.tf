# Variables TF File
variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "KeyPairName" {
  description = "EC2 instance key pair name"
  default     = "hwsndbx"
}

variable "project" { default = "openvpn-hadoop" }
variable "opnvpn_os" { default = "openvpn" }
variable "opnvpn_ami" { default = "ami-037ff6453f0855c46" }
variable "opnvpn_instance_type" { default = "t2.micro" }
