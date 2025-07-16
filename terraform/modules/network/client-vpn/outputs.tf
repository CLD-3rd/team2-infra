output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.this.id
}

output "client_vpn_endpoint_arn" {
  description = "ARN of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.this.arn
}

output "client_vpn_endpoint_dns_name" {
  description = "DNS name of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.this.dns_name
}

output "security_group_id" {
  description = "ID of the security group"
  value       = var.create_security_group ? aws_security_group.client_vpn[0].id : null
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = var.create_security_group ? aws_security_group.client_vpn[0].arn : null
}

output "network_association_ids" {
  description = "IDs of the network associations"
  value       = aws_ec2_client_vpn_network_association.this[*].id
}

output "authorization_rule_ids" {
  description = "IDs of the authorization rules"
  value       = aws_ec2_client_vpn_authorization_rule.this[*].id
}

output "route_ids" {
  description = "IDs of the routes"
  value       = aws_ec2_client_vpn_route.this[*].id
}