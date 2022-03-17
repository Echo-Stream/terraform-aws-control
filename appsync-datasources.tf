###################
### Datasources ###
###################
module "appsync_datasource_" {
  api_id                   = aws_appsync_graphql_api.echostream.id
  description              = "Main Lambda datasource for the echo-stream API "
  invoke_lambda_policy_arn = module.appsync_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_datasource.arn
  name                     = replace("${var.resource_prefix}_appsync_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.4"
}

resource "aws_appsync_datasource" "appsync_datasource_" {
  api_id      = aws_appsync_graphql_api.echostream.id
  description = var.description

  lambda_config {
    function_arn = var.lambda_function_arn
  }

  name             = var.name
  service_role_arn = aws_iam_role.lambda_datasource_role.arn
  type             = "AWS_LAMBDA"
}