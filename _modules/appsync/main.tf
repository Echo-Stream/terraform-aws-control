resource "aws_appsync_graphql_api" "echostream" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.echostream_appsync.arn
    field_log_level          = "ERROR"
  }

  user_pool_config {
    default_action = "ALLOW"
    user_pool_id   = var.user_pool_id
  }

  schema = var.schema
  xray_enabled = false
  name         = "${var.resource_prefix}-api"

  tags         = local.tags
}