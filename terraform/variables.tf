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