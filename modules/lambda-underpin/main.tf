resource "aws_sns_topic" "lambda_dead_letter" {
  display_name = "${var.resource_prefix}-lambda-dead-letter"
  name         = "${var.resource_prefix}-lambda-dead-letter"
  tags         = var.tags
}

resource "aws_sns_topic_subscription" "lambda_dead_letter" {
  endpoint  = var.support_email
  protocol  = "email"
  topic_arn = aws_sns_topic.lambda_dead_letter.arn
}

resource "aws_kms_key" "lambda_environment_variables" {
  description         = "Key for lambda environment variables ${var.resource_prefix}"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "lambda_environment_variables" {
  name          = "alias/${var.resource_prefix}-lambda-environment-variables"
  target_key_id = aws_kms_key.lambda_environment_variables.key_id
}
