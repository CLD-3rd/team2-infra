variable "service_name" {
  description = "Name of the service to be deployed"
  type        = string
  default     = "SaveMyPodo"
  
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "alert_emails_raw" {
  type = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

# 테라폼 실행 전에 acm 인증서 올리고 환경 변수로 설정해야 하는 변수들
variable "vpn_server_certificate_arn" {
  description = "ARN of the server certificate for Client VPN"
  type        = string
}

variable "vpn_root_ca_certificate_arn" {
  description = "ARN of the root CA certificate for Client VPN"
  type        = string
  default     = null
  
}

locals {
  alert_emails = split(",", var.alert_emails_raw)
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}
variable "google_smtp_password" {
  description = "Google SMTP password"
  type        = string
  sensitive   = true
}

variable "rds_admin_password" {
  description = "RDS admin password"
  type        = string
  sensitive   = true
  
}
