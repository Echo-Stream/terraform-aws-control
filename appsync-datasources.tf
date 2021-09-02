# ###################
# ### Datasources ###
# ###################

module "appsync_datasource_" {
  api_id                   = aws_appsync_graphql_api.echostream.id
  description              = "Main Lambda datasource for the echo-stream API "
  invoke_lambda_policy_arn = module.appsync_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_datasource.arn
  name                     = replace("${var.resource_prefix}_appsync_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.4"
}

# module "appsync_kms_key_lambda_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Lambda datasource that manages SQS/KMS resource and IAM policies from a Dynamodb Stream"
#   invoke_lambda_policy_arn = module.appsync_kms_key_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_kms_key_datasource.arn
#   name                     = replace("${var.resource_prefix}_kms_key_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "appsync_edge_lambda_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for managing edges"
#   invoke_lambda_policy_arn = module.appsync_edge_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_edge_datasource.arn
#   name                     = replace("${var.resource_prefix}_edge_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "appsync_graph_table_datasource" {
#   api_id              = aws_appsync_graphql_api.echostream.id
#   description         = "graph-table dynamodb datasource"
#   dynamodb_table_arn  = module.graph_table.arn
#   dynamodb_table_name = module.graph_table.name
#   name                = replace("${var.resource_prefix}_dynamodb", "-", "_")
#   source              = "QuiNovas/appsync-dynamodb-datasource/aws"
#   version             = "3.0.4"
# }

# resource "aws_appsync_datasource" "none" {
#   api_id = aws_appsync_graphql_api.echostream.id
#   name   = "none"
#   type   = "NONE"
# }

# module "validate_function_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for Validate function"
#   invoke_lambda_policy_arn = module.appsync_validate_function_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_validate_function_datasource.arn
#   name                     = replace("${var.resource_prefix}_validate_function", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "tenant_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-tenant-datasource function"
#   invoke_lambda_policy_arn = module.appsync_tenant_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_tenant_datasource.arn
#   name                     = replace("${var.resource_prefix}_tenant_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "app_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-app-datasource function"
#   invoke_lambda_policy_arn = module.appsync_app_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_app_datasource.arn
#   name                     = replace("${var.resource_prefix}_app_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "message_type_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-app-datasource function"
#   invoke_lambda_policy_arn = module.appsync_message_type_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_message_type_datasource.arn
#   name                     = replace("${var.resource_prefix}_message_type_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "sub_field_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-sub-field-datasource function"
#   invoke_lambda_policy_arn = module.appsync_sub_field_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_sub_field_datasource.arn
#   name                     = replace("${var.resource_prefix}_sub_field_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "large_message_storage_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-large-message-storage-datasource function"
#   invoke_lambda_policy_arn = module.appsync_large_message_storage_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_large_message_storage_datasource.arn
#   name                     = replace("${var.resource_prefix}_large_message_storage_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "node_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-node-datasource function"
#   invoke_lambda_policy_arn = module.appsync_node_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_node_datasource.arn
#   name                     = replace("${var.resource_prefix}_node_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }


# module "subscription_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-subscription-datasource function"
#   invoke_lambda_policy_arn = module.appsync_subscription_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_subscription_datasource.arn
#   name                     = replace("${var.resource_prefix}_subscription_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "function_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-function-datasource function"
#   invoke_lambda_policy_arn = module.appsync_function_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_function_datasource.arn
#   name                     = replace("${var.resource_prefix}_function_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "api_user_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-api-user-datasource function"
#   invoke_lambda_policy_arn = module.appsync_api_user_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_api_user_datasource.arn
#   name                     = replace("${var.resource_prefix}_api_user_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }

# module "integration_datasource" {
#   api_id                   = aws_appsync_graphql_api.echostream.id
#   description              = "Appsync lambda datasource for appsync-integrations-datasource function"
#   invoke_lambda_policy_arn = module.appsync_integrations_datasource.invoke_policy_arn
#   lambda_function_arn      = module.appsync_integrations_datasource.arn
#   name                     = replace("${var.resource_prefix}__integrations_datasource", "-", "_")
#   source                   = "QuiNovas/appsync-lambda-datasource/aws"
#   version                  = "3.0.4"
# }