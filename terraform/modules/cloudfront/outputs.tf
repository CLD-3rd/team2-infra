output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "oac_arn" {
  value       = var.use_oac && length(aws_cloudfront_origin_access_control.this) > 0 ? aws_cloudfront_origin_access_control.this[0].arn : null
  description = "ARN of the CloudFront Origin Access Control (OAC)"
}