resource "aws_appsync_graphql_api" "echostream" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  log_config {
    cloudwatch_logs_role_arn = var.appsync_service_role_arn
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
# ###################
# module "appsync_datasource_" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Main Lambda datasource for the echo-stream API "
#   invoke_lambda_policy_arn = var.invoke_policy_arn
#   lambda_function_arn      = aws_lambda_function.appsync_datasource.arn
#   name                     = replace("${var.name}_appsync_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }


resource "aws_appsync_datasource" "appsync_datasource_" {
  api_id      = aws_appsync_graphql_api.echostream.id
  description = "Main Lambda datasource for the echo-stream API "

  lambda_config {
    function_arn = aws_lambda_function.appsync_datasource.arn
  }

  name             = replace("${var.name}_appsync_datasource", "-", "_")
  service_role_arn = var.appsync_service_role_arn
  type             = "AWS_LAMBDA"
}

resource "aws_appsync_domain_name" "echostream_appsync" {
  domain_name     = var.api_domain_name
  certificate_arn = var.api_acm_arn
}

resource "aws_appsync_domain_name_api_association" "echostream_appsync" {
  api_id      = aws_appsync_graphql_api.echostream.id
  domain_name = aws_appsync_domain_name.echostream_appsync.domain_name
}