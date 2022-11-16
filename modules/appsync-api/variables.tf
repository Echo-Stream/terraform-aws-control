variable "api_acm_arn" {
  description = "ACM certificate arn for the domain being used for environment - api"
  type        = string
}

variable "api_domain_name" {
  description = "Api Domain name of the environment used for custom domain of Appsync API"
  type        = string
}

variable "appsync_datasource_lambda_role_arn" {
  description = "The ARN of the appsync datasource lambda role that has basic + necessary permissions"
  type        = string
}

variable "appsync_service_role_arn" {
  description = "The ARN of the appsync service role that can write logs"
  type        = string
}

variable "artifacts_bucket" {
  description = "Artifacts bucket name"
  type        = string
}

variable "dead_letter_arn" {
  description = "The arn for the SNS topic that handles dead letters"
  type        = string
}

variable "environment_variables" {
  default = {
    DEFAULT = "default"
  }
  description = "The map of environment variables to give to the Lambda function"
  type        = map(any)
}

variable "function_layers" {
  description = "List of layer version arns"
  type        = list(string)
}

variable "function_s3_object_key" {
  description = "S3 object key for the lambda function"
  type        = string
}

variable "kms_key_arn" {
  description = "The arn of the KMS key used to encrypt the environment variables"
  type        = string
}

variable "resource_prefix" {
  description = "Name that will be prefixed to the resource name"
  type        = string
}

variable "runtime" {
  description = "Runtime for the lambda"
  type        = string
}

variable "schema" {
  description = "Appsync schema"
  type        = string
}

variable "support_email" {
  type = string
}

variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}

variable "userpool_id" {
  description = "App user pool id that is used for authentication"
  type        = string
}