variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names for the certificate"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Validation method for the certificate"
  type        = string
  default     = "DNS"
}

variable "zone_id" {
  description = "Route53 hosted zone ID for DNS validation"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the certificate"
  type        = map(string)
  default     = {}
}