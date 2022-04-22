variable "allowed_account_id" {
  description = "The Account Id which hosts the environment"
  type        = string
}

variable "domain_name" {
  description = "Your root domain, Used to fetch the hosted_zone_id and create webapp/appsync dns"
}

variable "authorized_domains" {
  description = "List of authorized_domains that can signup to the app"
  type        = list(string)
}

variable "echostream_version" {
  description = "Major.Minor Version to fetch artifacts from right location"
  type        = string
}

variable "region" {
  description = "AWS Region for the environment"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for naming resources. Lower case only, No periods"
}

variable "route53_account_id" {
  description = "The AWS Account ID, where EchoStream Route53 resides"
  type        = string
}

variable "route53_manager_role_name" {
  description = "The Name of the role that needs to be assumed to managed DNS records in Corp/EchoStream Route53"
  type        = string
}

variable "ses_email_address" {
  description = "Preferred Email Address that SES uses for communication with tenants"
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "tenant_regions" {
  description = "List of Tenant regions"
  type        = any
  default     = []
}

variable "environment" {
  description = "Environment. Could be dev, stg, prod"
}
