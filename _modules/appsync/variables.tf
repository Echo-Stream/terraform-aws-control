variable "user_pool_id" {
  description = "App user pool id that is used for authentication"
  type        = string
}

variable "appsync_role_arn" {
  description = "The ARN of the appsync role that can write logs"
  type        = string
}