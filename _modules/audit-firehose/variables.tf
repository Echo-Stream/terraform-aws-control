
variable "region" {
  description = "Name of the region"
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

variable "resource_prefix" {
  description = "Prefix for naming resources. Lower case only, No periods"
}
