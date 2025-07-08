variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "create_zone" {
  description = "Whether to create a new hosted zone"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Existing hosted zone ID (if not creating new)"
  type        = string
  default     = ""
}

variable "records" {
  description = "List of DNS records to create"
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string), [])
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }), null)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the hosted zone"
  type        = map(string)
  default     = {}
}