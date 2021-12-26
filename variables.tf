variable "app_acm_arn" {
  description = "ACM certificate arn for the domain being used for environment - application"
  type        = string
}

variable "api_acm_arn" {
  description = "ACM certificate arn for the domain being used for environment - api"
  type        = string
}

variable "allowed_account_id" {
  description = "The Account Id which hosts the environment"
  type        = string
}

variable "authorized_domains" {
  description = "List of authorized_domains that can signup to the app"
  type        = list(string)
}

variable "app_domain_name" {
  description = "Application Domain name of the environment which may be used for Cognito custom auth, SES domain Identity and Cloudfront custom domain"
  type        = string
}

variable "api_domain_name" {
  description = "Api Domain name of the environment used for custom domain of Appsync API"
  type        = string
}

variable "echostream_version" {
  description = "Major.Minor Version to fetch artifacts from right location"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for naming resources. Lower case only, No periods"
}

variable "region" {
  description = "AWS Region for the environment"
  type        = string
}

variable "ses_email_address" {
  description = "Preferred Email Address that SES uses for communication with tenants"
  type        = string
}

variable "tenant_regions" {
  description = "List of Tenant regions"
  type        = any
  default     = []
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}