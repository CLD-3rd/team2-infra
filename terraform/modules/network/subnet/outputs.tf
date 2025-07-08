output "subnet_ids" {
  description = "IDs of the subnets"
  value       = aws_subnet.this[*].id
  sensitive   = true
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [for i, subnet in aws_subnet.this : subnet.id if var.subnets[i].public]
  sensitive   = true
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [for i, subnet in aws_subnet.this : subnet.id if !var.subnets[i].public]
  sensitive   = true
}