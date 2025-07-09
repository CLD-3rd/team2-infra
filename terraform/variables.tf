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



locals {
  alert_emails = split(",", var.alert_emails_raw)
}