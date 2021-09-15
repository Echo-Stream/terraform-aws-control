###############
## Mutations ##
###############
resource "aws_appsync_resolver" "create_api_user" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateApiUser"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_bitmapper_function" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateBitmapperFunction"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_app_change_notification" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateAppChangeNotification"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_cross_account_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateCrossAccountApp"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_cross_tenant_receiving_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateCrossTenantReceivingApp"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_cross_tenant_sending_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateCrossTenantSendingApp"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_cross_tenant_sending_node" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateCrossTenantSendingNode"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_edge" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateEdge"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_external_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateExternalApp"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_external_node" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateExternalNode"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_kms_key" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateKmsKey"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_managed_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateManagedApp"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_managed_node" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateManagedNode"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_managed_node_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateManagedNodeType"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateMessageType"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_router_node" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateRouterNode"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateTenant"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_transformer_function" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateTransformerFunction"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

resource "aws_appsync_resolver" "create_transformer_node" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateTransformerNode"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Mutation"
}

#############
## Queries ##
#############

resource "aws_appsync_resolver" "get_api_user" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetApiUser"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetApp"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_bulk_data_storage" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetBulkDataStorage"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_edge" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetEdge"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_function" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetFunction"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_kms_key" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetKmsKey"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_managed_node_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetManagedNodeType"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetMessageType"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_node" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetNode"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetTenant"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_tenant_user" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetTenantUser"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "get_user" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "GetUser"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "list_api_users" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListApiUsers"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "list_apps" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListApps"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "list_functions" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListFunctions"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "list_kms_keys" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListKmsKeys"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "list_nodes" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListNodes"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "list_managed_node_types" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListManagedNodeTypes"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "list_message_types" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListMessageTypes"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "list_tenants" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListTenants"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "list_tenant_users" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListTenantUsers"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

## Alert Emitter Node
resource "aws_appsync_resolver" "alert_emitter_node_sendmessagetype" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "AlertEmitterNode"
}

resource "aws_appsync_resolver" "alert_emitter_node_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "AlertEmitterNode"
}

## api user
resource "aws_appsync_resolver" "api_user_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ApiUser"
}

resource "aws_appsync_resolver" "api_user_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ApiUser"
}

resource "aws_appsync_resolver" "api_user_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ApiUser"
}

resource "aws_appsync_resolver" "api_user_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ApiUser"
}

## BitmapperFunction

resource "aws_appsync_resolver" "bitmapper_function_argumentMessageType" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "argumentMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "BitmapperFunction"
}

resource "aws_appsync_resolver" "bitmapper_function_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "BitmapperFunction"
}

resource "aws_appsync_resolver" "bitmapper_function_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "BitmapperFunction"
}

resource "aws_appsync_resolver" "bitmapper_function_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "BitmapperFunction"
}

resource "aws_appsync_resolver" "bitmapper_function_validate" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Validate"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "BitmapperFunction"
}

## ChangeEmitterNode
resource "aws_appsync_resolver" "change_emitter_node_sendMessageType" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ChangeEmitterNode"
}

resource "aws_appsync_resolver" "change_emitter_node_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ChangeEmitterNode"
}

# AppChangeNotification
resource "aws_appsync_resolver" "app_change_notification_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "AppChangeNotification"
}

## CrossAccountApp
resource "aws_appsync_resolver" "cross_account_app_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossAccountApp"
}

resource "aws_appsync_resolver" "cross_account_app_nodes" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "nodes"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossAccountApp"
}

resource "aws_appsync_resolver" "cross_account_app_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossAccountApp"
}

resource "aws_appsync_resolver" "cross_account_app_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossAccountApp"
}

resource "aws_appsync_resolver" "cross_account_app_reset_password" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ResetPassword"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossAccountApp"
}

resource "aws_appsync_resolver" "cross_account_app_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossAccountApp"
}

## CrossTenantReceivingApp

resource "aws_appsync_resolver" "cross_tenant_receiving_app_nodes" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "nodes"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingApp"
}

resource "aws_appsync_resolver" "cross_tenant_receiving_app_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingApp"
}

resource "aws_appsync_resolver" "cross_tenant_receiving_app_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingApp"
}

resource "aws_appsync_resolver" "cross_tenant_receiving_app_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingApp"
}

## CrossTenantReceivingNode
resource "aws_appsync_resolver" "cross_tenant_receiving_node_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "app"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingNode"
}

resource "aws_appsync_resolver" "cross_tenant_receiving_node_send_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingNode"
}

resource "aws_appsync_resolver" "cross_tenant_receiving_node_send_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingNode"
}

resource "aws_appsync_resolver" "cross_tenant_receiving_node_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingNode"
}

resource "aws_appsync_resolver" "cross_tenant_receiving_node_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingNode"
}

resource "aws_appsync_resolver" "cross_tenant_receiving_node_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantReceivingNode"
}

## CrossTenantSendingApp
resource "aws_appsync_resolver" "cross_tenant_sending_app_nodes" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "nodes"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingApp"
}

resource "aws_appsync_resolver" "cross_tenant_sending_app_receiving_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receivingApp"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingApp"
}

resource "aws_appsync_resolver" "cross_tenant_sending_app_receiving_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receivingTenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingApp"
}

resource "aws_appsync_resolver" "cross_tenant_sending_app_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingApp"
}

resource "aws_appsync_resolver" "cross_tenant_sending_app_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingApp"
}

resource "aws_appsync_resolver" "cross_tenant_sending_app_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingApp"
}

## CrossTenantSendingNode
resource "aws_appsync_resolver" "cross_tenant_sending_node_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "app"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

resource "aws_appsync_resolver" "cross_tenant_sending_node_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

resource "aws_appsync_resolver" "cross_tenant_sending_node_managed_transformer" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "managedTransformer"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

resource "aws_appsync_resolver" "cross_tenant_sending_node_receive_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

resource "aws_appsync_resolver" "cross_tenant_sending_node_receive_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

resource "aws_appsync_resolver" "cross_tenant_sending_node_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

resource "aws_appsync_resolver" "cross_tenant_sending_node_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

resource "aws_appsync_resolver" "cross_tenant_sending_node_list_log_events" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListLogEvents"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

resource "aws_appsync_resolver" "cross_tenant_sending_node_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

resource "aws_appsync_resolver" "cross_tenant_sending_node_validate" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Validate"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "CrossTenantSendingNode"
}

## Edge
resource "aws_appsync_resolver" "edge_kms_key" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "kmsKey"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

resource "aws_appsync_resolver" "edge_message_counts" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "messageCounts"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

resource "aws_appsync_resolver" "edge_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "messageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

resource "aws_appsync_resolver" "edge_source" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "source"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

resource "aws_appsync_resolver" "edge_target" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "target"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

resource "aws_appsync_resolver" "edge_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

resource "aws_appsync_resolver" "edge_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

resource "aws_appsync_resolver" "edge_move" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Move"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

resource "aws_appsync_resolver" "edge_purge" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Purge"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

resource "aws_appsync_resolver" "edge_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Edge"
}

## ExternalApp
resource "aws_appsync_resolver" "external_app_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalApp"
}

resource "aws_appsync_resolver" "external_app_nodes" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "nodes"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalApp"
}

resource "aws_appsync_resolver" "external_app_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalApp"
}

resource "aws_appsync_resolver" "external_app_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalApp"
}

resource "aws_appsync_resolver" "external_app_reset_password" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ResetPassword"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalApp"
}

resource "aws_appsync_resolver" "external_app_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalApp"
}

## ExternalNode
resource "aws_appsync_resolver" "external_node_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "app"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalNode"
}

resource "aws_appsync_resolver" "external_node_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalNode"
}

resource "aws_appsync_resolver" "external_node_receive_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalNode"
}

resource "aws_appsync_resolver" "external_node_receive_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalNode"
}

resource "aws_appsync_resolver" "external_node_send_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalNode"
}

resource "aws_appsync_resolver" "external_node_send_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalNode"
}

resource "aws_appsync_resolver" "external_node_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalNode"
}

resource "aws_appsync_resolver" "external_node_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalNode"
}

resource "aws_appsync_resolver" "external_node_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ExternalNode"
}

## LogEmitterNode
resource "aws_appsync_resolver" "log_emitter_node_send_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "LogEmitterNode"
}

resource "aws_appsync_resolver" "log_emitter_node_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "LogEmitterNode"
}

## LoginUser
resource "aws_appsync_resolver" "login_user_tenant_users" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenantUsers"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "LoginUser"
}

## KmsKey
resource "aws_appsync_resolver" "kms_key_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "KmsKey"
}

resource "aws_appsync_resolver" "kms_key_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "KmsKey"
}

resource "aws_appsync_resolver" "kms_key_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "KmsKey"
}

## ManagedApp
resource "aws_appsync_resolver" "managed_app_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedApp"
}

resource "aws_appsync_resolver" "managed_app_managed_instances" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "managedInstances"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedApp"
}

resource "aws_appsync_resolver" "managed_app_nodes" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "nodes"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedApp"
}

resource "aws_appsync_resolver" "managed_app_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedApp"
}

resource "aws_appsync_resolver" "managed_app_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedApp"
}

resource "aws_appsync_resolver" "managed_app_deregister_managed_instance" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "DeregisterManagedInstance"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedApp"
}

resource "aws_appsync_resolver" "managed_app_reset_password" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ResetPassword"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedApp"
}

resource "aws_appsync_resolver" "managed_app_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedApp"
}

## ManagedInstance
resource "aws_appsync_resolver" "managed_instance_last_ping_date_time" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "lastPingDateTime"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedInstance"
}

resource "aws_appsync_resolver" "managed_instance_ping_status" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "pingStatus"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedInstance"
}

## ManagedNode
resource "aws_appsync_resolver" "managed_node_app" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "app"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_managed_node_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "managedNodeType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_receive_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_receive_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_send_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_send_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_list_log_events" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListLogEvents"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

resource "aws_appsync_resolver" "managed_node_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNode"
}

## ManagedNodeType
resource "aws_appsync_resolver" "managed_node_type_receive_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNodeType"
}

resource "aws_appsync_resolver" "managed_node_type_send_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNodeType"
}

resource "aws_appsync_resolver" "managed_node_type_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNodeType"
}

resource "aws_appsync_resolver" "managed_node_type_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNodeType"
}

resource "aws_appsync_resolver" "managed_node_type_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ManagedNodeType"
}

## MessageType
resource "aws_appsync_resolver" "message_type_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "MessageType"
}

resource "aws_appsync_resolver" "message_type_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "MessageType"
}

resource "aws_appsync_resolver" "message_type_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "MessageType"
}

resource "aws_appsync_resolver" "message_type_validate" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Validate"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "MessageType"
}

## RouterNode
resource "aws_appsync_resolver" "router_node_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_managed_bitmapper" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "managedBitmapper"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_receive_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_receive_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_send_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_send_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_list_log_events" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListLogEvents"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

resource "aws_appsync_resolver" "router_node_validate" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Validate"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "RouterNode"
}

## Subscription
resource "aws_appsync_resolver" "subscription_on_app_change" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "onAppChange"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Subscription"
}

## Tenant
resource "aws_appsync_resolver" "tenant_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Tenant"
}

resource "aws_appsync_resolver" "tenant_users" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "users"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Tenant"
}

resource "aws_appsync_resolver" "tenant_add_user" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "AddUser"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Tenant"
}

resource "aws_appsync_resolver" "tenant_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Tenant"
}

resource "aws_appsync_resolver" "tenant_list_changes" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListChanges"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Query"
}

resource "aws_appsync_resolver" "tenant_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "Tenant"
}

## TenantUser
resource "aws_appsync_resolver" "tenant_user_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TenantUser"
}

resource "aws_appsync_resolver" "tenant_user_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TenantUser"
}

resource "aws_appsync_resolver" "tenant_user_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TenantUser"
}

resource "aws_appsync_resolver" "tenant_user_first_name" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "firstName"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TenantUser"
}

resource "aws_appsync_resolver" "tenant_user_last_name" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "lastName"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TenantUser"
}

## TransformerFunction
resource "aws_appsync_resolver" "transformer_function_argument_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "argumentMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerFunction"
}

resource "aws_appsync_resolver" "transformer_function_result_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "returnMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerFunction"
}

resource "aws_appsync_resolver" "transformer_function_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerFunction"
}

resource "aws_appsync_resolver" "transformer_function_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerFunction"
}

resource "aws_appsync_resolver" "transformer_function_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerFunction"
}

resource "aws_appsync_resolver" "transformer_function_validate" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Validate"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerFunction"
}

## TransformerNode
resource "aws_appsync_resolver" "transformer_node_config" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "config"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_managed_transformer" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "managedTransformer"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_receive_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_receive_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "receiveMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_send_edges" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendEdges"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_send_message_type" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "sendMessageType"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_delete" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Delete"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_list_log_events" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListLogEvents"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_update" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Update"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}

resource "aws_appsync_resolver" "transformer_node_validate" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "Validate"
  request_template  = file("${path.module}/files/invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "TransformerNode"
}
