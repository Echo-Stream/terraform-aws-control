resource "aws_sns_topic" "lambda_dead_letter" {
  display_name = "${var.name}-lambda-dead-letter"
  name         = "${var.name}-lambda-dead-letter"
  tags         = var.tags
}

resource "aws_kms_key" "lambda_environment_variables" {
  description         = "Key for lambda environment variables ${var.name}"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "lambda_environment_variables" {
  name          = "alias/${var.name}-lambda-environment-variables"
  target_key_id = aws_kms_key.lambda_environment_variables.key_id
}