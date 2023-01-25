#############
## API Key ##
#############
resource "aws_secretsmanager_secret" "api_key" {
  description = "The Stripe API Key"
  name        = var.stripe_api_key_secret_name
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "api_key" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key
}

######################
## Webhook Endpoint ##
######################
resource "stripe_webhook_endpoint" "echostream" {
  enabled_events = ["*"]
  description    = "Webhook endpoint for echostream"
  url            = var.webhook_url
}

resource "aws_secretsmanager_secret" "webhook_secret" {
  description = "The Stripe Webhook Secret"
  name        = var.stripe_webhook_secret_secret_name
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "webhook_secret" {
  secret_id     = aws_secretsmanager_secret.webhook_secret.id
  secret_string = stripe_webhook_endpoint.echostream.secret
}
