variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = false
}

variable "enable_website" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "index_document" {
  description = "Index document for website hosting"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for website hosting"
  type        = string
  default     = "error.html"
}

variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public policy"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public buckets"
  type        = bool
  default     = true
}

variable "bucket_policy" {
  description = "Bucket policy JSON"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}