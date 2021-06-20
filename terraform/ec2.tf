locals {
  stage_app_name      = "${var.AppName}-${terraform.workspace}"
  storage_volume_name = "data-${var.AppName}-${terraform.workspace}"
  connection_type     = "ssh"
  default_username    = "ec2-user"
  user_data_source = "./scripts/user_data.sh"
  script_source       = "./scripts/setup_script.sh"
  script_destination  = "/etc/setup_script.sh"
}

# EC2 resource
resource "aws_instance" "web_hwsdbx" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.KeyPairName
  subnet_id              = var.subnet_id
  vpc_security_group_ids = ["${aws_security_group.sg_web_hwsdbx.id}"]
  user_data = file(local.user_data_source)

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

  connection {
    type     = local.connection_type
    user     = lookup(var.aws_instance_connection_username, var.ami_type, local.default_username)
    password = var.aws_instance_connection_password
    host     = self.public_ip
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "file" {
    source      = local.script_source
    destination = local.script_destination
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.script_destination}",
      "bash ${local.script_destination} ${local.stage_app_name}"
    ]
  }
}
