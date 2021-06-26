# Outputs.tf
output "instance_id" {
  description = "Instance ID of the instance"
  value       = aws_instance.web_hwsdbx.id
}

output "instance_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.web_hwsdbx.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the instance"
  value       = aws_instance.web_hwsdbx.public_dns
}

output "hadoop_elastic_ip" {
  description = "Hadoop elastic IP attached to the instance"
  value       = aws_eip_association.eip_assoc_hadoop.public_ip
}



