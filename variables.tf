variable "authorized_domains" {
  description = "List of authorized_domains that can signup to the app"
  type        = list(string)
  default     = []
}

variable "check_domains" {
  description = "Controls whether we use authorized domains or not"
  type        = bool
  default     = false
}

variable "create_dynamo_db_replication_service_role" {
  description = "Enable boolean to create a dynamo db replication service role"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Your root domain, Used to fetch the hosted_zone_id and create webapp/appsync dns"
}

variable "echostream_version" {
  description = "Major.Minor Version to fetch artifacts from right location"
  type        = string
}

variable "environment" {
  description = "Environment. Could be dev, stg, prod"
}

variable "resource_prefix" {
  description = "Prefix for naming resources. Lower case only, No periods"
}

variable "ses_email_address" {
  description = "Preferred Email Address that SES uses for communication with tenants"
  type        = string
}

variable "stripe_api_key" {
  default     = ""
  description = "The API key for Stripe"
  sensitive   = true
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "tenant_regions" {
  description = "List of Tenant regions"
  type        = list(string)
}