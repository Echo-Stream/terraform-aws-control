resource "aws_secretsmanager_secret" "paddle_api_key" {
  description = "The Paddle API Key"
  name        = "paddle_api_key"
}

resource "aws_secretsmanager_secret_version" "paddle_api_key" {
  secret_id     = aws_secretsmanager_secret.paddle_api_key.id
  secret_string = var.paddle_api_key
}

resource "aws_secretsmanager_secret" "paddle_webhooks_secret" {
  description = "The Paddle Webhooks secret"
  name        = "paddle_webhooks_secret"
}

resource "aws_secretsmanager_secret_version" "paddle_webhooks_secret" {
  secret_id     = aws_secretsmanager_secret.paddle_webhooks_secret.id
  secret_string = var.paddle_webhooks_secret
}
