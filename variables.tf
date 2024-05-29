variable "authorized_domains" {
  default     = []
  description = "List of authorized_domains that can signup to the app"
  type        = list(string)
}

variable "billing_enabled" {
  default     = false
  description = "True is billing is enabled via Paddle."
  type        = bool
}

variable "check_domains" {
  default     = false
  description = "Controls whether we use authorized domains or not"
  type        = bool
}

variable "create_dynamo_db_replication_service_role" {
  default     = true
  description = "Enable boolean to create a dynamo db replication service role"
  type        = bool
}

variable "domain_name" {
  description = "Your root domain, Used to fetch the hosted_zone_id and create webapp/appsync dns"
  type        = string
}

variable "echostream_version" {
  description = "Major.Minor Version to fetch artifacts from right location"
  type        = string
}

variable "environment" {
  description = "Environment. Could be dev, stg, prod"
  type        = string
}

variable "paddle_api_key" {
  description = "Paddle API Key"
  sensitive   = true
  type        = string
}

variable "paddle_client_side_token" {
  description = "Paddle Client-side Token"
  type        = string
}

variable "paddle_price_ids" {
  description = "Paddle Price IDs"
  type        = map(string)
}

variable "paddle_product_ids" {
  description = "Paddle Product IDs"
  type        = map(string)
}

variable "paddle_webhooks_secret" {
  default     = ""
  description = "Paddle Webhooks Secret"
  sensitive   = true
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for naming resources. Lower case only, No periods"
  type        = string
}

variable "ses_email_address" {
  description = "Preferred Email Address that SES uses for communication with tenants"
  type        = string
}

variable "tags" {
  default     = {}
  description = "(Optional) A mapping of tags to assign to the resources"
  type        = map(string)
}

variable "tenant_regions" {
  description = "List of Tenant regions"
  type        = list(string)
}
