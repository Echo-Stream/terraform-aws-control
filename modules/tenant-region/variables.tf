variable "app_cognito_pre_authentication_environment_variables" {
  type = map(any)
}

variable "app_cognito_pre_authentication_function_s3_object_key" {
  type = string
}

variable "app_cognito_pre_authentication_lambda_role_arn" {
  type = string
}

variable "appsync_datasource_function_s3_object_key" {
  type = string
}

variable "appsync_datasource_lambda_role_arn" {
  type = string
}

variable "appsync_service_role_arn" {
  type = string
}

variable "artifacts_bucket_prefix" {
  type = string
}

variable "audit_firehose_log_group" {
  type = string
}

variable "common_lambda_environment_variables" {
  type = map(any)
}

variable "lambda_runtime" {
  type = string
}

variable "regional_api_acm_arns" {
  type = map(any)
}

variable "regional_domain_names" {
  type = map(any)
}

variable "resource_prefix" {
  description = "Name that will be prefixed to the resource name"
  type        = string
}

variable "schema" {
  description = "Appsync schema"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}

variable "zone_id" {
  type = string
}
