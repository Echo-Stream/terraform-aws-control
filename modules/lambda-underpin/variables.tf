variable "name" {
  description = "Name that will be prefixed to the resource name"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}