variable "name" {
  description = "Name prefix for Client VPN resources"
  type        = string
}

variable "description" {
  description = "Description for the Client VPN endpoint"
  type        = string
  default     = "Client VPN endpoint"
}

variable "vpc_id" {
  description = "VPC ID where Client VPN will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with Client VPN"
  type        = list(string)
}

variable "client_cidr_block" {
  description = "IPv4 address range for VPN clients"
  type        = string
  default     = "10.0.0.0/16"
}

variable "server_certificate_arn" {
  description = "ARN of the server certificate"
  type        = string
}

variable "root_ca_certificate_arn" {
  description = "ARN of the root CA certificate"
  type        = string
  default     = null
}

variable "authentication_type" {
  description = "Authentication type (certificate-authentication or federated-authentication)"
  type        = string
  default     = "certificate-authentication"
}

variable "connection_logging_enabled" {
  description = "Enable connection logging"
  type        = bool
  default     = false
}

variable "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  type        = string
  default     = null
}

variable "cloudwatch_log_stream" {
  description = "CloudWatch log stream name"
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = []
}

variable "split_tunnel" {
  description = "Enable split tunnel"
  type        = bool
  default     = false
}

variable "transport_protocol" {
  description = "Transport protocol (tcp or udp)"
  type        = string
  default     = "udp"
}

variable "vpn_port" {
  description = "VPN port number"
  type        = number
  default     = 443
}

variable "authorization_rules" {
  description = "List of authorization rules"
  type = list(object({
    target_network_cidr  = string
    access_group_id      = optional(string)
    authorize_all_groups = optional(bool)
    description          = optional(string)
  }))
  default = []
}

variable "routes" {
  description = "List of routes"
  type = list(object({
    destination_cidr_block = string
    target_vpc_subnet_id   = string
    description            = optional(string)
  }))
  default = []
}

variable "create_security_group" {
  description = "Create security group for Client VPN"
  type        = bool
  default     = true
}

variable "security_group_ingress_rules" {
  description = "List of ingress rules for security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string)
  }))
  default = []
}

variable "security_group_egress_rules" {
  description = "List of egress rules for security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}