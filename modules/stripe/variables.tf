variable "api_key" {
  description = "The API key for Stripe"
  sensitive   = true
  type        = string
}

variable "resource_prefix" {
  description = "Name that will be prefixed to the resource name"
  type        = string
}

variable "stripe_api_key_secret_name" {
  description = "The name of the secret that will contain the Stripe API Key"
  type        = string
}

variable "stripe_webhook_secret_secret_name" {
  description = "The name of the secret that will contain the Stripe Webhook Secret"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources created by this module"
  type        = map(string)
}

variable "webhook_url" {
  description = "The URL of the Stripe Webhooks Receiver"
  type        = string
}
