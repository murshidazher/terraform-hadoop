locals {
  stage_app_name      = "${var.AppName}-${terraform.workspace}"
  storage_volume_name = "data-${var.AppName}-${terraform.workspace}"
  connection_type     = "ssh"
  default_username    = "ec2-user"
  user_data_source    = "./scripts/user_data.sh"
  script_source       = "./scripts/setup_script.sh"
  script_destination  = "/etc/setup_script.sh"
}

# EC2 resource
resource "aws_instance" "web_hwsdbx" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.KeyPairName
  subnet_id              = aws_subnet.external-02.id
  vpc_security_group_ids = [aws_security_group.sg_web_hwsdbx.id]
  user_data              = file(local.user_data_source)

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

# creating elastic ip to have a stable public ip to connect to instance
resource "aws_eip" "eip_web_hwsdbx" {
  instance = aws_instance.web_hwsdbx.id
  vpc      = true

  tags = {
    Name = "eip-${local.stage_app_name}"
  }
}

# attach to the ec2 instance
resource "aws_eip_association" "eip_assoc_hadoop" {
  instance_id   = aws_instance.web_hwsdbx.id
  allocation_id = aws_eip.eip_web_hwsdbx.id
}

resource "null_resource" "reboot_hadoop" {
  provisioner "local-exec" {
    on_failure  = fail
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
        echo -e "\x1B[31m Warning! Restarting instance having id ${aws_instance.web_hwsdbx.id}.................. \x1B[0m"
        aws ec2 reboot-instances --instance-ids ${aws_instance.web_hwsdbx.id} --profile edutf
        echo "==> Rebooted"
     EOT
  }
}

resource "null_resource" "stop_hadoop" {
  provisioner "local-exec" {
    on_failure  = fail
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
        echo -e "\x1B[31m Warning! Stopping instance having id ${aws_instance.web_hwsdbx.id}.................. \x1B[0m"
        # To stop instance
        aws ec2 stop-instances --instance-ids ${aws_instance.web_hwsdbx.id} --profile edutf
        echo "==> Stopped"
     EOT
  }
}
