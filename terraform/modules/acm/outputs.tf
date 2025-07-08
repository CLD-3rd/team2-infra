output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.this.status
}