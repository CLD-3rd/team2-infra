variable "role_name" {
  type = string
}

variable "github_repo_pattern" {
  type = string
}

variable "policy_arns" {
  type    = list(string)
  default = []
}

variable "inline_policies" {
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}