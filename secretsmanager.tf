resource "aws_secretsmanager_secret" "paddle_api_key" {
  description = "The Paddle API Key"
  name        = "paddle_api_key"
}

resource "aws_secretsmanager_secret_version" "paddle_api_key" {
  secret_id     = aws_secretsmanager_secret.paddle_api_key.id
  secret_string = var.paddle_api_key
}
