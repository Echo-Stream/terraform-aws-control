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

####################
## Resolvers ##
####################

data "aws_s3_bucket_object" "response_template_default_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/response-templates/default.vtl"
}

data "aws_s3_bucket_object" "request_template_GetUsersForTenant_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request-templates/GetUsersForTenant.vtl"
}
resource "aws_appsync_resolver" "GetUsersForTenant" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "GetUsersForTenant"
  type        = "Query"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_GetUsersForTenant_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}


###ListKeys


data "aws_s3_bucket_object" "request_template_validate_user_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request-templates/validate_user.vtl"
}

resource "aws_appsync_resolver" "ListKeys" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "ListKeys"
  type        = "Query"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}
####################
## Datasources ##
####################


## Datasources ##
module "appsync_kms_key_lambda_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Lambda datasource that manages SQS/KMS resource and IAM policies from a Dynamodb Stream"
  invoke_lambda_policy_arn = module.appsync_kms_key_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_kms_key_datasource.arn
  name                     = replace("${var.environment_prefix}_kms_key_datasource","-","_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}

module "appsync_edge_lambda_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Appsync lambda datasource for managing edges"
  invoke_lambda_policy_arn = module.appsync_edge_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_edge_datasource.arn
  name                     = replace("${var.environment_prefix}_edge_datasource","-","_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}

module "appsync_hl7_ninja_graph_table_datasource" {
  api_id              = aws_appsync_graphql_api.hl7_ninja.id
  description         = "hl7-ninja-graph-table dynamodb datasource"
  dynamodb_table_arn  = module.hl7_ninja_graph_table.arn
  dynamodb_table_name = module.hl7_ninja_graph_table.name
  name                = replace("${var.environment_prefix}_dynamodb","-","_")
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
  name                     = replace("${var.environment_prefix}_validate_function","-","_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}

module "tenant_datasource" {
  api_id                   = aws_appsync_graphql_api.hl7_ninja.id
  description              = "Appsync lambda datasource for appsync-tenant-datasource function"
  invoke_lambda_policy_arn = module.appsync_tenant_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_tenant_datasource.arn
  name                     = replace("${var.environment_prefix}_tenant_datasource","-","_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.2"
}
