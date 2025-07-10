variable "key_name" {
  description = "The name of the SSM parameter"
  type        = string
}

variable "value" {
  description = "The value of the SSM parameter"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the SSM parameter"
  type        = map(string)
  default     = {}
}