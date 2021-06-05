# Outputs.tf
output "instance_id" {
  description = " Instance ID of the instance"
  value       = aws_instance.web-hwsdbx.id
}

output "instance_ip" {
  description = " Public IP of the instance"
  value       = aws_instance.web-hwsdbx.public_ip
}

output "instance_public_dns" {
  description = " Public DNS of the instance"
  value       = aws_instance.web-hwsdbx.public_dns
}
