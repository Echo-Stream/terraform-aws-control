variable "artifacts_bucket" {
  description = "Artifacts bucket name"
  type        = string
}

variable "control_region" {
  description = "Control region name, e.g us-east-1"
  type        = string
}

variable "tenant_region" {
  description = "tenant region name, e.g us-east-1"
  type        = string
}

variable "dead_letter_arn" {
  description = "The arn for the SNS topic that handles dead letters"
  type        = string
}

variable "environment" {
  description = "value for environment variable in lambda"
  type        = string
}

variable "function_s3_object_key" {
  description = "S3 object key for the lambda function"
  type        = string
}

variable "graph_table_name" {
  description = "Graph table name"
  type        = string
}

variable "kms_key_arn" {
  description = "The arn of the KMS key used to encrypt the environment variables"
  type        = string
}

variable "name" {
  description = "Name that will be prefixed to the resource name"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}

variable "tenant_regions" {
  description = "Json encoded list of tenant regions"
  type        = any
}

variable "app_cognito_pre_authentication_lambda_role_arn" {
  description = "The IAM role arn for the app cognito pre authentication lambda, which should have all necessary permissions"
  type        = string
}