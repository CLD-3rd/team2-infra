variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "name" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

variable "tags" {
  description = "Additional tags for the Internet Gateway"
  type        = map(string)
  default     = {}
}