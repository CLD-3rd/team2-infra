# Website outputs
output "website_url" {
  description = "Website URL"
  value       = "https://${local.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = module.cdn.distribution_id
}

output "s3_bucket_name" {
  description = "S3 bucket name for website hosting"
  value       = module.website_bucket.bucket_id
}

# Database outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

# Cache outputs
output "redis_cluster_address" {
  description = "Redis cluster address"
  value       = module.elasticache.cluster_address
  sensitive   = true
}

output "redis_port" {
  description = "Redis port"
  value       = 6379
}

# Network outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.subnets.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.subnets.public_subnet_ids
}

# EKS outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks.cluster_version
}

output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.oidc_issuer_url
}

output "eks_aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.eks.aws_load_balancer_controller_role_arn
}

output "eks_karpenter_role_arn" {
  description = "ARN of the Karpenter IAM role"
  value       = module.eks.karpenter_role_arn
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.nat_gateway.nat_gateway_public_ip
}

# Client VPN outputs
output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = module.client_vpn.client_vpn_endpoint_id
  sensitive   = true
}

output "client_vpn_dns_name" {
  description = "DNS name of the Client VPN endpoint"
  value       = module.client_vpn.client_vpn_endpoint_dns_name
}

output "image_cdn_domain_name" {
  description = "Domain name of the Image CDN distribution"
  value       = module.image_cdn.distribution_domain_name
}

output "oidc_role_arn" {
  value = module.github_oidc_role.role_arn
}
