####################
## GraphQL Schema ##
####################

data "aws_s3_bucket_object" "graphql_schema" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/schema.graphql"
}

resource "aws_appsync_graphql_api" "hl7_ninja" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.hl7_ninja_appsync.arn
    field_log_level          = "ERROR"
  }

  user_pool_config {
    default_action = "ALLOW"
    user_pool_id   = aws_cognito_user_pool.hl7_ninja_apps.id
  }

  additional_authentication_provider {
    authentication_type = "AMAZON_COGNITO_USER_POOLS"

    user_pool_config {
      user_pool_id = aws_cognito_user_pool.hl7_ninja_ui.id
    }
  }

  schema = data.aws_s3_bucket_object.graphql_schema.body

  name = "${var.environment_prefix}-api"
  tags = local.tags
}

resource "aws_iam_role" "hl7_ninja_appsync" {
  name               = "${var.environment_prefix}-appsync"
  assume_role_policy = data.aws_iam_policy_document.appsync_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "hl7_ninja_appsync" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
  role       = aws_iam_role.hl7_ninja_appsync.name
}

/*
## Datasources ##
module "appsync_kms_key_lambda_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Lambda datasource that manages SQS/KMS resource and IAM policies from a Dynamodb Stream"
  invoke_lambda_policy_arn = module.appsync_kms_key_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_kms_key_datasource.arn
  name                     = "kms_key_datasource"
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.1"
}

module "appsync_edge_lambda_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Appsync lambda datasource for managing edges"
  invoke_lambda_policy_arn = module.appsync_edge_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_edge_datasource.arn
  name                     = "edge_datasource"
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.1"
}

module "appsync_hl7_ninja_graph_table_datasource" {
  api_id              = aws_appsync_graphql_api.hl7_ninja.id
  description         = "hl7-ninja-graph-table dynamodb datasource"
  dynamodb_table_arn  = module.hl7_ninja_graph_table.arn
  dynamodb_table_name = module.hl7_ninja_graph_table.name
  name                = "dynamodb"
  source              = "QuiNovas/appsync-dynamodb-datasource/aws"
  version             = "3.0.0"
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
  name                     = "validate_function"
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.1"
}

module "tenant_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Appsync lambda datasource for appsync-tenant-datasource function"
  invoke_lambda_policy_arn = module.appsync_tenant_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_tenant_datasource.arn
  name                     = "tenant_datasource"
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.1"
}
*/