variable "allowed_account_id" {
  description = "The Account Id which hosts the environment"
  type        = string
}

variable "hl7_ninja_version" {
  description = "Major.Minor Version to fetch artifacts from right location"
  type        = string
}

variable "environment_prefix" {
  description = "Environment Prefix for naming resources, a Unique name that could differentiate whole environment. Lower case only, No periods"
  type        = string
}

variable "domain_name" {
  description = "Domain (which is created in pre-control TF), which may be used for Cognito custom auth, SES domain Identity and Cloudfront custom domain"
  type        = string
}

variable "ses_email_address" {
  description = "Preferred Email Address that SES uses for communication with tenants"
  type        = string
}

variable "region" {
  description = "AWS Region for the environment"
  type        = string
}

variable "acm_arn" {
  description = "ACM certificate arn for the domain being used for environment"
  type        = string
}