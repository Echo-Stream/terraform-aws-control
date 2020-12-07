variable "environment_prefix" {
  description = "Environment Prefix for naming resources, a Unique name that could differentiate whole environment. Lower case only, No periods"
  type        = string
}

variable "tags" {
  description = "Resource Tags"
  type        = map(string)
  default     = {}
}