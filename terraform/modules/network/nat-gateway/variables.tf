variable "name" {
  description = "Name for the NAT Gateway"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the NAT Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the NAT Gateway"
  type        = map(string)
  default     = {}
}