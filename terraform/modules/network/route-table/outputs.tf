output "route_table_ids" {
  description = "IDs of the route tables"
  value       = aws_route_table.this[*].id
  sensitive   = true
}