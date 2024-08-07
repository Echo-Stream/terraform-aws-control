variable "artifacts_bucket" {
  description = "Artifacts bucket name"
  type        = string
}

variable "environment_variables" {
  default = {
    DEFAULT = "default"
  }
  description = "The map of environment variables to give to the Lambda function"
  type        = map(any)
}

variable "dead_letter_arn" {
  description = "The arn for the SNS topic that handles dead letters"
  type        = string
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

variable "name" {
  description = "Name that will be prefixed to the resource name"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}


variable "app_cognito_pre_authentication_lambda_role_arn" {
  description = "The IAM role arn for the app cognito pre authentication lambda, which should have all necessary permissions"
  type        = string
}

variable "runtime" {
  description = "Runtime for the lambda"
  type        = string
}
