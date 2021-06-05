locals {
  stage_app_name = "${var.AppName}-${terraform.workspace}"
}

# EC2 resource
resource "aws_instance" "web-nginx" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.KeyPairName
  subnet_id              = var.subnet_id
  vpc_security_group_ids = ["${aws_security_group.webnginx.id}"]

  user_data = file("user-data.sh") # also known as provisioners

  tags = {
    Name        = local.stage_app_name
    Environment = "${terraform.workspace}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Adding Security Group for our Instance :
resource "aws_security_group" "webnginx" {
  name        = "web-nginx"
  description = "Nginx Web Server Security Group"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.HostIp}"]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["${var.HostIp}"]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${var.PvtIp}"]
    # cidr_blocks = ["0.0.0.0/0"]
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
