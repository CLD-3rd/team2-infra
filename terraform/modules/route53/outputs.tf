output "zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = local.zone_id
}

output "zone_arn" {
  description = "ARN of the Route53 hosted zone"
  value       = var.create_zone ? aws_route53_zone.this[0].arn : null
}

output "name_servers" {
  description = "Name servers for the hosted zone"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : null
  sensitive   = true
}