
variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}

variable "lambdas" {
    default = {}
    description = "list of lambda functions for which alarm is to be created."
    type = map(string)
}
  
variable "alarm_actions" {
    default = []
    description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
    type = list(string)
}


variable "ok_actions" {
    default = []
    description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
    type = list(string)
}