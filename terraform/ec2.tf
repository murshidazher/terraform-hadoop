locals {
  stage_app_name      = "${var.AppName}-${terraform.workspace}"
  storage_volume_name = "data-${var.AppName}-${terraform.workspace}"
}

# EC2 resource
resource "aws_instance" "web-hwsdbx" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.KeyPairName
  subnet_id              = var.subnet_id
  vpc_security_group_ids = ["${aws_security_group.webhwsdbx.id}"]

  user_data = file("./scripts/user-data.sh") # also known as provisioners

  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    delete_on_termination = var.delete_storage_on_termination

    tags = {
      Name        = local.storage_volume_name
      Environment = "${terraform.workspace}"
    }
  }

  tags = {
    Name        = local.stage_app_name
    Environment = "${terraform.workspace}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Adding Security Group for our Instance :
resource "aws_security_group" "webhwsdbx" {
  name        = "web-hwsdbx"
  description = "HortonWorks Sandbox Web Server Security Group"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["${var.HostIp}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #cidr_blocks = ["${var.HostIp}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.PvtIp}"]
    #cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    #cidr_blocks = ["${var.HostIp}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.PvtIp}"]
    #cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
