output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
  sensitive = true
}