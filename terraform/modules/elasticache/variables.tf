variable "cluster_id" {
  description = "Group identifier for the ElastiCache cluster"
  type        = string
}

variable "engine" {
  description = "Name of the cache engine to be used for this cache cluster"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "Version number of the cache engine"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "The instance class used"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "The initial number of cache nodes that the cache cluster will have"
  type        = number
  default     = 1
}

variable "parameter_group_name" {
  description = "Name of the parameter group to associate with this cache cluster"
  type        = string
  default     = "default.redis7"
}

variable "port" {
  description = "The port number on which each of the cache nodes will accept connections"
  type        = number
  default     = 6379
}

variable "subnet_group_name" {
  description = "Name of the subnet group to be used for the cache cluster"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "One or more VPC security groups associated with the cache cluster"
  type        = list(string)
}

variable "at_rest_encryption_enabled" {
  description = "Whether to enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Whether to enable encryption in transit"
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "The password used to access a password protected server"
  type        = string
  default     = null
  sensitive   = true
}

variable "maintenance_window" {
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "snapshot_retention_limit" {
  description = "The number of days for which ElastiCache will retain automatic cache cluster snapshots"
  type        = number
  default     = 3
}

variable "snapshot_window" {
  description = "The daily time range during which ElastiCache will begin taking a daily snapshot"
  type        = string
  default     = "03:00-05:00"
}

variable "create_subnet_group" {
  description = "Whether to create a cache subnet group"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}