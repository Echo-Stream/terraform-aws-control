###################
### Datasources ###
###################
module "appsync_kms_key_lambda_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Lambda datasource that manages SQS/KMS resource and IAM policies from a Dynamodb Stream"
  invoke_lambda_policy_arn = module.appsync_kms_key_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_kms_key_datasource.arn
  name                     = replace("${var.environment_prefix}_kms_key_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}

module "appsync_edge_lambda_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Appsync lambda datasource for managing edges"
  invoke_lambda_policy_arn = module.appsync_edge_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_edge_datasource.arn
  name                     = replace("${var.environment_prefix}_edge_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}

module "appsync_graph_table_datasource" {
  api_id              = aws_appsync_graphql_api.hl7_ninja.id
  description         = "hl7-ninja-graph-table dynamodb datasource"
  dynamodb_table_arn  = module.graph_table.arn
  dynamodb_table_name = module.graph_table.name
  name                = replace("${var.environment_prefix}_dynamodb", "-", "_")
  source              = "QuiNovas/appsync-dynamodb-datasource/aws"
  version             = "3.0.2"
}

resource "aws_appsync_datasource" "none" {
  api_id = aws_appsync_graphql_api.hl7_ninja.id
  name   = "none"
  type   = "NONE"
}

module "validate_function_lambda_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Appsync lambda datasource for Validate function"
  invoke_lambda_policy_arn = module.validate_function.invoke_policy_arn
  lambda_function_arn      = module.validate_function.arn
  name                     = replace("${var.environment_prefix}_validate_function", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}

module "tenant_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Appsync lambda datasource for appsync-tenant-datasource function"
  invoke_lambda_policy_arn = module.appsync_tenant_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_tenant_datasource.arn
  name                     = replace("${var.environment_prefix}_tenant_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}

module "app_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Appsync lambda datasource for appsync-app-datasource function"
  invoke_lambda_policy_arn = module.appsync_app_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_app_datasource.arn
  name                     = replace("${var.environment_prefix}_app_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}

module "message_type_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Appsync lambda datasource for appsync-app-datasource function"
  invoke_lambda_policy_arn = module.appsync_message_type_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_message_type_datasource.arn
  name                     = replace("${var.environment_prefix}_message_type_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}