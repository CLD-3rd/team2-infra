# Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = var.description
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block
  
  authentication_options {
    type                       = var.authentication_type
    root_certificate_chain_arn = var.root_ca_certificate_arn
  }
  
  connection_log_options {
    enabled               = var.connection_logging_enabled
    cloudwatch_log_group  = var.cloudwatch_log_group
    cloudwatch_log_stream = var.cloudwatch_log_stream
  }
  
  dns_servers    = var.dns_servers
  split_tunnel   = var.split_tunnel
  transport_protocol = var.transport_protocol
  vpn_port       = var.vpn_port
  
  tags = var.tags
}

# Client VPN Network Association
resource "aws_ec2_client_vpn_network_association" "this" {
  count                  = length(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = var.subnet_ids[count.index]
  
  lifecycle {
    ignore_changes = [subnet_id]
  }
}

# Client VPN Authorization Rule
resource "aws_ec2_client_vpn_authorization_rule" "this" {
  count                  = length(var.authorization_rules)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.authorization_rules[count.index].target_network_cidr
  access_group_id        = lookup(var.authorization_rules[count.index], "access_group_id", null)
  authorize_all_groups   = lookup(var.authorization_rules[count.index], "authorize_all_groups", false)
  description            = lookup(var.authorization_rules[count.index], "description", null)
}

# Client VPN Route
resource "aws_ec2_client_vpn_route" "this" {
  count                  = length(var.routes)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  destination_cidr_block = var.routes[count.index].destination_cidr_block
  target_vpc_subnet_id   = var.routes[count.index].target_vpc_subnet_id
  description            = lookup(var.routes[count.index], "description", null)
  
  depends_on = [aws_ec2_client_vpn_network_association.this]
}

# Security Group for Client VPN
resource "aws_security_group" "client_vpn" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.name}-client-vpn-sg"
  description = "Security group for Client VPN"
  vpc_id      = var.vpc_id
  
  dynamic "ingress" {
    for_each = var.security_group_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = lookup(ingress.value, "description", null)
    }
  }
  
  dynamic "egress" {
    for_each = var.security_group_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = lookup(egress.value, "description", null)
    }
  }
  
  tags = merge(var.tags, {
    Name = "${var.name}-client-vpn-sg"
  })
}