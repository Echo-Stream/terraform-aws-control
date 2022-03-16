variable "userpool_id" {
  description = "App user pool id that is used for authentication"
  type        = string
}

variable "schema" {
  description = "Appsync schema"
  type        = string
}

variable "appsync_datasource_lambda_role_arn" {
  description = "The ARN of the appsync datasource lambda role that has basic + necessary permissions"
  type        = string
}

variable "appsync_role_arn" {
  description = "The ARN of the appsync role that can write logs"
  type        = string
}


variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}

variable "name" {
  description = "Name that will be prefixed to the resource name"
  type        = string
}


variable "kms_key_arn" {
  description = "The arn of the KMS key used to encrypt the environment variables"
  type        = string
}

variable "dead_letter_arn" {
  description = "The arn for the SNS topic that handles dead letters"
  type        = string
}

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

variable "function_s3_object_key" {
  description = "S3 object key for the lambda function"
  type        = string
}

variable "invoke_policy_arn" {
  description = "The ARN of the IAM policy that has permissions to invoke the lambda; used by datasource"
  type        = string
}
