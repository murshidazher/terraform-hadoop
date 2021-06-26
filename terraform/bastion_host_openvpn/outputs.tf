# Outputs.tf
output "instance_id" {
  description = "Instance ID of the instance"
  value       = aws_instance.openvpn.id
}

output "openvpn_elastic_ip" {
  description = "OpenVPN elastic IP attached to the instance"
  value       = aws_eip_association.eip_assoc.public_ip
}

