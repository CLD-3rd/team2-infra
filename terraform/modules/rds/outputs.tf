output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_port" {
  description = "The RDS instance port"
  value       = aws_db_instance.this.port
}

output "db_instance_address" {
  description = "The RDS instance hostname"
  value       = aws_db_instance.this.address
}