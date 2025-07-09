variable "origin_domain_name" {
  description = "Domain name of the origin"
  type        = string
}

variable "origin_id" {
  description = "Unique identifier for the origin"
  type        = string
}

variable "aliases" {
  description = "List of domain aliases for the distribution"
  type        = list(string)
  default     = []
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate"
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Price class for the distribution"
  type        = string
  default     = "PriceClass_100"
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled"
  type        = bool
  default     = true
}

variable "custom_error_responses" {
  description = "Custom error responses"
  type = list(object({
    error_code         = number
    response_code      = number
    response_page_path = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the distribution"
  type        = map(string)
  default     = {}
}

variable "use_oac" {
  description = "Whether to use Origin Access Control (OAC)"
  type        = bool
  default     = false
}

variable "service_name" {
  description = "Service name for the CloudFront distribution"
  type        = string
}

variable "allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}