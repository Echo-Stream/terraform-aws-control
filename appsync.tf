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

#Queries

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

#### GetUser

resource "aws_appsync_resolver" "GetUser" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "GetUser"
  type        = "Query"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

#### SearchApps

resource "aws_appsync_resolver" "SearchApps" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "SearchApps"
  type        = "Query"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}
 ### SearchEdges 
resource "aws_appsync_resolver" "SearchEdges" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "SearchEdges"
  type        = "Query"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

### SearchNodes 
resource "aws_appsync_resolver" "SearchNodes" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "SearchNodes"
  type        = "Query"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

##### ValidateFunction

data "aws_s3_bucket_object" "request_template_validate_function_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request_templates/ValidateFunction.vtl"
}

resource "aws_appsync_resolver" "ValidateFunction" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "ValidateFunction"
  type        = "Query"

  request_template  = data.aws_s3_bucket_object.request_template_validate_function_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

#### mutations

resource "aws_appsync_resolver" "PutKmsKey" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutKmsKey"
  type        = "Mutation"
  data_source = module.appsync_kms_key_lambda_datasource.datasource_name


  request_template  = "{}"
  response_template = "{}"
}


resource "aws_appsync_resolver" "PutEdge" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutEdge"
  type        = "Mutation"
  data_source = module.appsync_edge_lambda_datasource.datasource_name


  request_template  = "{}"
  response_template = "{}"
}


resource "aws_appsync_resolver" "PutHl7MllpInboundNode" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutHl7MllpInboundNode"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}



resource "aws_appsync_resolver" "PutHl7MllpOutboundNode" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutHl7MllpOutboundNode"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}


resource "aws_appsync_resolver" "PutExternalNode" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutExternalNode"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "PutTenant" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutTenant"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "DeleteNode" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "DeleteNode"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "DeleteApp" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "DeleteApp"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "PutExternalApp" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutExternalApp"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "PutManagedApp" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutManagedApp"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "AddUserToTenant" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "AddUserToTenant"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "ResetAppPassword" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "ResetAppPassword"
  type        = "Mutation"
  data_source = module.appsync_hl7_ninja_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

## DeleteEdge

data "aws_s3_bucket_object" "request_templates_DeleteEdge_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request-templates/DeleteEdge.vtl"
}

resource "aws_appsync_resolver" "DeleteEdge" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "DeleteEdge"
  type        = "Mutation"
  data_source = module.appsync_edge_lambda_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_templates_DeleteEdge_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}


###### functions

# Query functions

#SearchNodes

data "aws_s3_bucket_object" "request_templates_SearchNodes_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request_templates/SearchNodes.vtl"
}

data "aws_s3_bucket_object" "response_templates_pass_result_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/response_templates/pass_result.vtl"
}


resource "aws_appsync_function" "SearchNodes" {
  api_id                    = aws_appsync_graphql_api.hl7_ninja.id
  data_source               = module.appsync_hl7_ninja_graph_table_datasource.datasource_name
  name                      = "SearchNodes"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_SearchNodes_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}


#SearchEdges
data "aws_s3_bucket_object" "request_templates_SearchEdges_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request_templates/SearchEdges.vtl"
}

resource "aws_appsync_function" "SearchEdges" {
  api_id                    = aws_appsync_graphql_api.hl7_ninja.id
  data_source               = module.appsync_hl7_ninja_graph_table_datasource.datasource_name
  name                      = "SearchEdges"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_SearchEdges_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

#SearchApps
data "aws_s3_bucket_object" "request_templates_SearchApps_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request_templates/SearchApps.vtl"
}

resource "aws_appsync_function" "SearchApps" {
  api_id                    = aws_appsync_graphql_api.hl7_ninja.id
  data_source               = module.appsync_hl7_ninja_graph_table_datasource.datasource_name
  name                      = "SearchApps"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_SearchApps_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}


#GetUser
data "aws_s3_bucket_object" "request_templates_GetUser_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request_templates/GetUser.vtl"
}

resource "aws_appsync_function" "GetUser" {
  api_id                    = aws_appsync_graphql_api.hl7_ninja.id
  data_source               = module.appsync_hl7_ninja_graph_table_datasource.datasource_name
  name                      = "GetUser"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_GetUser_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

#GetUsersForTenant

data "aws_s3_bucket_object" "request_templates_GetUsersForTenant_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request_templates/GetUsersForTenant.vtl"
}

resource "aws_appsync_function" "GetUsersForTenant" {
  api_id                    = aws_appsync_graphql_api.hl7_ninja.id
  data_source               = module.appsync_hl7_ninja_graph_table_datasource.datasource_name
  name                      = "GetUsersForTenant"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_GetUsersForTenant_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

#ListKeys

data "aws_s3_bucket_object" "request_templates_ListKeys_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts_prefix["appsync"]}/request_templates/ListKeys.vtl"
}

resource "aws_appsync_function" "ListKeys" {
  api_id                    = aws_appsync_graphql_api.hl7_ninja.id
  data_source               = module.appsync_hl7_ninja_graph_table_datasource.datasource_name
  name                      = "ListKeys"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_ListKeys_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

 # Mutation functions

####################
## Datasources ###
####################


## Datasources ##
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

module "appsync_hl7_ninja_graph_table_datasource" {
  api_id              = aws_appsync_graphql_api.hl7_ninja.id
  description         = "hl7-ninja-graph-table dynamodb datasource"
  dynamodb_table_arn  = module.hl7_ninja_graph_table.arn
  dynamodb_table_name = module.hl7_ninja_graph_table.name
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
