resource "aws_secretsmanager_secret" "paddle_api_key" {
  count       = var.billing_enabled ? 1 : 0
  description = "The Paddle API Key"
  name        = "paddle_api_key"
}

resource "aws_secretsmanager_secret_version" "paddle_api_key" {
  count         = var.billing_enabled ? 1 : 0
  secret_id     = aws_secretsmanager_secret.paddle_api_key[0].id
  secret_string = var.paddle_api_key
}

resource "aws_secretsmanager_secret" "paddle_webhooks_secret" {
  count       = var.billing_enabled ? 1 : 0
  description = "The Paddle Webhooks secret"
  name        = "paddle_webhooks_secret"
}

resource "aws_secretsmanager_secret_version" "paddle_webhooks_secret" {
  count         = var.billing_enabled ? 1 : 0
  secret_id     = aws_secretsmanager_secret.paddle_webhooks_secret[0].id
  secret_string = var.paddle_webhooks_secret
}
