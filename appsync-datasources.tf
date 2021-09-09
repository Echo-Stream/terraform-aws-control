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