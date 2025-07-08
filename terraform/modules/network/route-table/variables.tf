variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "route_tables" {
  description = "List of route table configurations"
  type = list(object({
    name       = string
    subnet_ids = list(string)
    routes = list(object({
      cidr_block = string
      gateway_id = optional(string)
      nat_gateway_id = optional(string)
    }))
    tags = optional(map(string), {})
  }))
}