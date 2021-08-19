variable "acm_arn" {
  description = "ACM certificate arn for the domain being used for environment"
  type        = string
}

variable "allowed_account_id" {
  description = "The Account Id which hosts the environment"
  type        = string
}

variable "domain_name" {
  description = "Domain (which is created in pre-control TF), which may be used for Cognito custom auth, SES domain Identity and Cloudfront custom domain"
  type        = string
}

variable "domain_zone_id" {
  description = "Domain Zone id(which is created in pre-control TF), which may be used for Cognito custom auth, SES domain Identity and Cloudfront custom domain"
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
  type        = list(string)
  default     = []
}

variable "manual_deployment_trigger" {
  description = "Toggle for deployment of all echo tenant and system types, appsync, cloudfront etc. Changing the previous existing value acts as a trigger"
  type        = string
  default     = "foobar"
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}