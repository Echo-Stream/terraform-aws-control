
variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}

variable "lambdas" {
    default = []
    description = "list of lambda functions for which alarm is to be created."
    type = map(string)
}
