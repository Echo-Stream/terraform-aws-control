resource "aws_appsync_graphql_api" "echostream" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  log_config {
    cloudwatch_logs_role_arn = var.appsync_role_arn
    field_log_level          = "ERROR"
  }

  user_pool_config {
    default_action = "ALLOW"
    user_pool_id   = var.userpool_id
  }

  schema       = var.schema
  xray_enabled = false
  name         = "${var.name}-api"

  tags = var.tags
}

###################
### Datasources ###
###################
module "appsync_datasource_" {
  api_id                   = aws_appsync_graphql_api.echostream.id
  description              = "Main Lambda datasource for the echo-stream API "
  invoke_lambda_policy_arn = var.invoke_policy_arn
  lambda_function_arn      = aws_lambda_function.appsync_datasource.arn
  name                     = replace("${var.name}_appsync_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.4"
}