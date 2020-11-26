variable "name" {
  description = "Name for resources"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}

variable "log_bucket" {
  description = "Log bucket id, must be in same region as source bucket"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key arn for SSE"
  type        = string
}
