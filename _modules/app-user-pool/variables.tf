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

variable "resource_prefix" {
  default     = []
  description = "A list of users/customers (normally root users) that can access the artifact bucket across accounts."
  type        = list(string)
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

variable "app_cognito_pre_authentication_iam_policy_arn" {
  description = "The IAM policy for the app cognito pre authentication lambda"
  type        = string
}

variable "graph_ddb_read_iam_policy_arn" {
  description = "The IAM policy for read only access to the graph-table"
  type        = string
}