variable "name" {
  description = "Name for resources"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}

variable "alarm_sns_topic_arn" {
  description = "Alarm SNS Topic ARN"
  type        = string
}

variable "account_id" {
  description = "Account ID of Control region"
  type        = string
}