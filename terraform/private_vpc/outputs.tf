# Outputs.tf
output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.main.id
  # sensitive = true
}

output "sbnet_ext01_ip" {
  description = "External 01 public subnet ip"
  value       = aws_subnet.external-01.id
  # sensitive = true
}

output "sbnet_ext02_ip" {
  description = "External 02 public subnet ip"
  value       = aws_subnet.external-02.id
  # sensitive = true
}


