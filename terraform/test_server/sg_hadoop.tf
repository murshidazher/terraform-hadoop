# Adding Security Group for our Instance :
resource "aws_security_group" "sg_web_hwsdbx" {
  name        = "sg_web_hwsdbx"
  description = "HortonWorks Sandbox Web Server Security Group"
  vpc_id      = data.terraform_remote_state.vpc_remote_state.outputs.vpc_id


  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["10.118.8.0/22", "${data.terraform_remote_state.openvpn_remote_state.outputs.openvpn_elastic_ip}/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["10.118.8.0/22", "${data.terraform_remote_state.openvpn_remote_state.outputs.openvpn_elastic_ip}/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["10.118.8.0/22", "${data.terraform_remote_state.openvpn_remote_state.outputs.openvpn_elastic_ip}/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["10.118.8.0/22", "${data.terraform_remote_state.openvpn_remote_state.outputs.openvpn_elastic_ip}/32"]
  }

  egress {
    description = "Allow outbound traffic from the server"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
