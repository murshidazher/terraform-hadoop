# Variables TF File
variable "region" {
  description = "AWS Region "
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to be used for Instance "
  default     = "ami-0ff8a91507f77f867"
}

variable "instance_type" {
  description = "Instance Typebe used for Instance "
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID to be used for Instance "
  default     = "subnet-41d6541d"
}

variable "AppName" {
  description = "Application Name"
  default     = "HortonWorksSandboxWebServer-Host"
}

variable "Env" {
  description = "Staging Environment Name"
  default     = "Dev"
}

variable "HostIp" {
  description = " Host IP to be allowed SSH for"
  default     = "103.21.166.191/32"
}

variable "PvtIp" {
  description = "Pvt IP to be allowed SSH for"
  default     = "10.12.0.0/16"
}
