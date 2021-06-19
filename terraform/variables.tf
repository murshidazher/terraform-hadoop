# Variables TF File
variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to be used for Instance "
  default     = "ami-0d5eff06f840b45e9"
}

variable "instance_type" {
  description = "Instance Typebe used for Instance "
  default     = "t2.xlarge"
}

variable "subnet_id" {
  description = "Subnet ID to be used for Instance "
  default     = "subnet-b4e9fdd3"
}

variable "volume_type" {
  description = "EC2 storage volume type"
  default     = "gp2" # gp2 | standard
}

variable "volume_size" {
  description = "EC2 storage volume size"
  default     = 80
}

variable "delete_storage_on_termination" {
  description = "Delete storage on termination"
  default     = true
}



variable "AppName" {
  description = "Application Name"
  default     = "HortonWorksSandboxWebServer"
}

variable "HostIp" {
  description = " Host IP to be allowed SSH for"
  default     = "203.189.185.187/32"
}

variable "PvtIp" {
  description = "Pvt IP to be allowed SSH for"
  default     = "10.12.0.0/16"
}

variable "KeyPairName" {
  description = "EC2 instance key pair name"
  default     = "hwsndbx"
}
