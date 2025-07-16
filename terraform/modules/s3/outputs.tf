output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "Website endpoint of the S3 bucket"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.this[0].website_endpoint : null
}

output "website_domain" {
  description = "Website domain of the S3 bucket"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.this[0].website_domain : null
}