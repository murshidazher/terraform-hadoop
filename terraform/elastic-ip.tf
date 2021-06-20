locals {
  stage_app_name = "${var.AppName}-${terraform.workspace}"
  stage_eip_name = "eip-${local.stage_app_name}"
}

# creating elastic ip to have a stable public ip to connect to instance
resource "aws_eip" "eip_web_hwsdbx" {
  instance = aws_instance.web_hwsdbx.id
  vpc      = true

  tags = {
    Name = local.stage_eip_name
  }

  lifecycle {
    prevent_destroy = true
  }
}

# attach to the ec2 instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web_hwsdbx.id
  allocation_id = aws_eip.eip_web_hwsdbx.id
}
