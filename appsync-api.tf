####################
## GraphQL Schema ##
####################

data "aws_s3_bucket_object" "graphql_schema" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/schema.graphql"
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


###############
## Resolvers ##
###############

# module "GetMessageType" {
#   api_id          = aws_appsync_graphql_api.hl7_ninja.id
#   field           = "GetMessageType"
#   type            = "Query"
#   datasource_name = module.message_type_datasource.datasource_name
#   source          = "./resolver"
# }

# module "GetUsersForTenant" {
#   api_id          = aws_appsync_graphql_api.hl7_ninja.id
#   field           = "GetUsersForTenant"
#   type            = "Query"
#   datasource_name = module.tenant_datasource.datasource_name
#   source          = "./resolver"
# }

# module "GetUser" {
#   api_id          = aws_appsync_graphql_api.hl7_ninja.id
#   field           = "GetUser"
#   type            = "Query"
#   datasource_name = module.tenant_datasource.datasource_name
#   source          = "./resolver"
# }


# resource "aws_appsync_resolver" "GetUsersForTenant" {
#   api_id      = aws_appsync_graphql_api.hl7_ninja.id
#   field       = "GetUsersForTenant"
#   type        = "Query"
#   data_source = module.appsync_graph_table_datasource.datasource_name
# }

/*

data "aws_s3_bucket_object" "response_template_default_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/response-templates/default.vtl"
}

data "aws_s3_bucket_object" "request_template_GetUsersForTenant_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/GetUsersForTenant.vtl"
}
resource "aws_appsync_resolver" "GetUsersForTenant" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "GetUsersForTenant"
  type        = "Query"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_GetUsersForTenant_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}


###ListKeys


data "aws_s3_bucket_object" "request_template_validate_user_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/validate_user.vtl"
}

resource "aws_appsync_resolver" "ListKeys" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "ListKeys"
  type        = "Query"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

#### GetUser

resource "aws_appsync_resolver" "GetUser" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "GetUser"
  type        = "Query"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

#### SearchApps

resource "aws_appsync_resolver" "SearchApps" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "SearchApps"
  type        = "Query"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}
### SearchEdges 
resource "aws_appsync_resolver" "SearchEdges" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "SearchEdges"
  type        = "Query"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

### SearchNodes 
resource "aws_appsync_resolver" "SearchNodes" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "SearchNodes"
  type        = "Query"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

##### ValidateFunction

data "aws_s3_bucket_object" "request_template_validate_function_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/ValidateFunction.vtl"
}

resource "aws_appsync_resolver" "ValidateFunction" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "ValidateFunction"
  type        = "Query"
  data_source = module.validate_function_lambda_datasource.datasource_name

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
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}



resource "aws_appsync_resolver" "PutHl7MllpOutboundNode" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutHl7MllpOutboundNode"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}


resource "aws_appsync_resolver" "PutExternalNode" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutExternalNode"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "PutTenant" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutTenant"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "DeleteNode" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "DeleteNode"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "DeleteApp" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "DeleteApp"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "PutExternalApp" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutExternalApp"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "PutManagedApp" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "PutManagedApp"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "AddUserToTenant" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "AddUserToTenant"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

resource "aws_appsync_resolver" "ResetAppPassword" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "ResetAppPassword"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_template_validate_user_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

## DeleteEdge

data "aws_s3_bucket_object" "request_templates_DeleteEdge_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/DeleteEdge.vtl"
}

resource "aws_appsync_resolver" "DeleteEdge" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "DeleteEdge"
  type        = "Mutation"
  data_source = module.appsync_graph_table_datasource.datasource_name

  request_template  = data.aws_s3_bucket_object.request_templates_DeleteEdge_vtl.body
  response_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}


###### functions

# Query functions

#SearchNodes

data "aws_s3_bucket_object" "request_templates_SearchNodes_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/SearchNodes.vtl"
}

data "aws_s3_bucket_object" "response_templates_pass_result_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/response-templates/pass_result.vtl"
}


resource "aws_appsync_function" "SearchNodes" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "SearchNodes"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_SearchNodes_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}


#SearchEdges
data "aws_s3_bucket_object" "request_templates_SearchEdges_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/SearchEdges.vtl"
}

resource "aws_appsync_function" "SearchEdges" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "SearchEdges"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_SearchEdges_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

#SearchApps
data "aws_s3_bucket_object" "request_templates_SearchApps_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/SearchApps.vtl"
}

resource "aws_appsync_function" "SearchApps" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "SearchApps"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_SearchApps_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}


#GetUser
data "aws_s3_bucket_object" "request_templates_GetUser_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/GetUser.vtl"
}

resource "aws_appsync_function" "GetUser" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "GetUser"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_GetUser_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

#GetUsersForTenant

data "aws_s3_bucket_object" "request_templates_GetUsersForTenant_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/GetUsersForTenant.vtl"
}

resource "aws_appsync_function" "GetUsersForTenant" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "GetUsersForTenant"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_GetUsersForTenant_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

#ListKeys

data "aws_s3_bucket_object" "request_templates_ListKeys_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/ListKeys.vtl"
}

resource "aws_appsync_function" "ListKeys" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "ListKeys"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_ListKeys_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

###### Mutation functions

### PutNode

data "aws_s3_bucket_object" "request_templates_PutNode_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/PutNode.vtl"
}

resource "aws_appsync_function" "PutNode" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "PutNode"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_PutNode_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

## PutTenant

data "aws_s3_bucket_object" "request_templates_PutTenant_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/PutTenant.vtl"
}

resource "aws_appsync_function" "PutTenant" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "PutTenant"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_PutTenant_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

## PutApp

data "aws_s3_bucket_object" "request_templates_PutApp_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/PutApp.vtl"
}

resource "aws_appsync_function" "PutApp" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "PutApp"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_PutApp_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}

## GetSourceEdges

data "aws_s3_bucket_object" "request_templates_GetSourceEdges_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/GetSourceEdges.vtl"
}

data "aws_s3_bucket_object" "response_templates_error_on_result_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/response-templates/error_on_result.vtl"
}

resource "aws_appsync_function" "GetSourceEdges" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "GetSourceEdges"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_GetSourceEdges_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_error_on_result_vtl.body
}


## GetTargetEdges

data "aws_s3_bucket_object" "request_templates_GetTargetEdges_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/GetTargetEdges.vtl"
}

resource "aws_appsync_function" "GetTargetEdges" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "GetTargetEdges"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_GetTargetEdges_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_error_on_result_vtl.body
}

# DeleteNode
data "aws_s3_bucket_object" "request_templates_DeleteNode_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/DeleteNode.vtl"
}

resource "aws_appsync_function" "DeleteNode" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "DeleteNode"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_DeleteNode_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_template_default_vtl.body
}

## GetAppNodes

data "aws_s3_bucket_object" "request_templates_GetAppNodes_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/GetAppNodes.vtl"
}

resource "aws_appsync_function" "GetAppNodes" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "GetAppNodes"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_GetAppNodes_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_error_on_result_vtl.body
}

## DeleteApp
data "aws_s3_bucket_object" "request_templates_DeleteApp_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/DeleteApp.vtl"
}

resource "aws_appsync_function" "DeleteApp" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "DeleteApp"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_DeleteApp_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}


#  AddUserToTenant
data "aws_s3_bucket_object" "request_templates_AddUserToTenantvtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/AddUserToTenant.vtl"
}

resource "aws_appsync_function" "AddUserToTenant" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "AddUserToTenant"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_AddUserToTenantvtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}


#  GetApp

data "aws_s3_bucket_object" "request_templates_GetApp_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/GetApp.vtl"
}

resource "aws_appsync_function" "GetApp" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "GetApp"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_GetApp_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}


#  ResetPassword

data "aws_s3_bucket_object" "request_templates_ResetAppPassword_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/ResetAppPassword.vtl"
}

resource "aws_appsync_function" "ResetPassword" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  data_source = module.appsync_graph_table_datasource.datasource_name
  name        = "ResetPassword"

  request_mapping_template  = data.aws_s3_bucket_object.request_templates_ResetAppPassword_vtl.body
  response_mapping_template = data.aws_s3_bucket_object.response_templates_pass_result_vtl.body
}


#####  subscriptions

/*data "aws_s3_bucket_object" "request_templates_onStreamNotifications_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/request-templates/onStreamNotifications.vtl"
}

data "aws_s3_bucket_object" "response_templates_onStreamNotifications_vtl" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/response-templates/onStreamNotifications.vtl"
}

resource "aws_appsync_resolver" "onStreamNotifications" {
  api_id      = aws_appsync_graphql_api.hl7_ninja.id
  field       = "onStreamNotifications"
  type        = "Subscription"
  data_source = aws_appsync_datasource.none.name

  request_template  = data.aws_s3_bucket_object.request_templates_onStreamNotifications_vtl.body
  response_template = data.aws_s3_bucket_object.response_templates_onStreamNotifications_vtl.body
}
*/

