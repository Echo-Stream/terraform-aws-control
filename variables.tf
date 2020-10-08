variable "allowed_account_id" {
  description = "The Account which hosts the environment"
}

variable "hl7_ninja_version" {
  description = "Major.Minor Version to fetch artifacts from right location"
}

variable "environment_prefix" {
  description = "Environment Prefix for naming resources, a Unique name that could differentiate whole environment"
}

variable "domain_name" {
  description = "Domain Name will used to create a subdomain, which will/may be used for Cognito custom auth, SES domain Identity and UI"
}

variable "ses_email_address" {
  description = "Preferred Email Address that SES uses for communication with tenants"
}

variable "region" {
  description = "AWS Region for the environment"
}