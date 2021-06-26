locals {
  stage_eip_name = "eip-${var.project}"
}

resource "aws_instance" "openvpn" {
  ami                         = var.opnvpn_ami
  instance_type               = var.opnvpn_instance_type
  key_name                    = var.KeyPairName
  subnet_id                   = data.terraform_remote_state.vpc_remote_state.outputs.sbnet_ext01_ip
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_web.id]
  tags = {
    Name = "${var.project}-web"
    OS   = var.opnvpn_os
  }
}


# creating elastic ip to have a stable public ip to connect to instance
resource "aws_eip" "eip_openvpn" {
  instance = aws_instance.openvpn.id
  vpc      = true

  tags = {
    Name = local.stage_eip_name
  }
}

# attach to the ec2 instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.openvpn.id
  allocation_id = aws_eip.eip_openvpn.id
}

# resource "null_resource" "reboot_openvpn" {
#   provisioner "local-exec" {
#     on_failure  = fail
#     interpreter = ["/bin/bash", "-c"]
#     command     = <<EOT
#         echo -e "\x1B[31m Warning! Restarting instance having id ${aws_instance.openvpn.id}.................. \x1B[0m"
#         aws ec2 reboot-instances --instance-ids ${aws_instance.openvpn.id} --profile edutf
#         echo "==> Rebooted"
#      EOT
#   }
# }

# resource "null_resource" "stop_openvpn" {
#   provisioner "local-exec" {
#     on_failure  = fail
#     interpreter = ["/bin/bash", "-c"]
#     command     = <<EOT
#         echo -e "\x1B[31m Warning! Stopping instance having id ${aws_instance.openvpn.id}.................. \x1B[0m"
#         # To stop instance
#         aws ec2 stop-instances --instance-ids ${aws_instance.openvpn.id} --profile edutf
#         echo "==> Stopped"
#      EOT
#   }
# }
