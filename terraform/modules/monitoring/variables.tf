variable "alarm_name" {
  description = "Name of the CloudWatch alarm"
  type        = string
}

variable "metric_name" {
  description = "The name of the metric"
  type        = string
}

variable "namespace" {
  description = "The namespace of the metric"
  type        = string
}

variable "threshold" {
  description = "The value against which the statistic is compared"
  type        = number
}

variable "comparison_operator" {
  description = "The arithmetic operation to use when comparing the statistic and threshold"
  type        = string
  default     = "GreaterThanThreshold"
}

variable "dimensions" {
  description = "The dimensions for the metric"
  type        = map(string)
  default     = {}
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = list(string)
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "action_description" {
  description = "Response actions to be included in the alert email"
  type = string
}

variable "evaluation_periods" {
  description = "How many periods to evaluate"
  type        = number
  default     = 2
}

variable "period" {
  description = "Length of each period in seconds"
  type        = number
  default     = 300
}

variable "statistic" {
  description = "Statistic to use (e.g., Average)"
  type        = string
  default     = "Average"
}
