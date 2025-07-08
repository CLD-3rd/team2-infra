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