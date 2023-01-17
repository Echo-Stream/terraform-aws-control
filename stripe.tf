locals {
  stripe_api_key_secret_name        = "${var.resource_prefix}-stripe-api-key"
  stripe_webhook_secret_secret_name = "${var.resource_prefix}-stripe-webhook-secret"
}

module "stripe" {
  count = var.stripe_api_key == "" ? 0 : 1

  api_key                           = var.stripe_api_key
  resource_prefix                   = var.resource_prefix
  stripe_api_key_secret_name        = local.stripe_api_key_secret_name
  stripe_webhook_secret_secret_name = local.stripe_webhook_secret_secret_name
  tags                              = local.tags

  source = "./modules/stripe"
}