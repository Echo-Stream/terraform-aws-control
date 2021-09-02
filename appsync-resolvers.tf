# # We are using custom local exec resolvers,
# # as aws_appsync_resolver TF resource is behind.
# # TF resource doesn't support optional templates yet.
# # https://github.com/terraform-providers/terraform-provider-aws/issues/15593

# data "template_file" "resolver_sh" {
#   template = file("${path.module}/scripts/resolvers.sh")
#   vars = {
#     api_id                           = aws_appsync_graphql_api.echostream.id
#     api_user_datasource              = module.api_user_datasource.name
#     app_datasource                   = module.app_datasource.name
#     edge_datasource                  = module.appsync_edge_lambda_datasource.name
#     function_datasource              = module.function_datasource.name
#     integration_datasource           = module.integration_datasource.name
#     kms_key_datasource               = module.appsync_kms_key_lambda_datasource.name
#     large_message_storage_datasource = module.large_message_storage_datasource.name
#     message_type_datasource          = module.message_type_datasource.name
#     node_datasource                  = module.node_datasource.name
#     sub_field_datasource             = module.sub_field_datasource.name
#     subscription_datasource          = module.subscription_datasource.name
#     templates_path                   = "${path.module}/files/response-template.vtl"
#     tenant_datasource                = module.tenant_datasource.name
#     validate_function_datasource     = module.validate_function_datasource.name
#   }
# }

# resource "null_resource" "all_resolvers" {
#   depends_on = [
#     data.template_file.resolver_sh,
#     module.api_user_datasource.name,
#     module.appsync_edge_lambda_datasource,
#     module.appsync_kms_key_lambda_datasource,
#     module.function_datasource,
#     module.integration_datasource,
#     module.large_message_storage_datasource,
#     module.message_type_datasource,
#     module.node_datasource,
#     module.sub_field_datasource,
#     module.subscription_datasource,
#     module.tenant_datasource,
#     module.validate_function_datasource,
#   ]

#   provisioner "local-exec" {
#     command = "./ ${data.template_file.resolver_sh.rendered}"
#   }
#   triggers = {
#     api_id                           = aws_appsync_graphql_api.echostream.id
#     api_user_datasource              = module.api_user_datasource.name
#     app_datasource                   = module.app_datasource.name
#     deploy                           = data.template_file.resolver_sh.rendered
#     edge_datasource                  = module.appsync_edge_lambda_datasource.name
#     function_datasource              = module.function_datasource.name
#     integration_datasource           = module.integration_datasource.name
#     large_message_storage_datasource = module.large_message_storage_datasource.name
#     message_type_datasource          = module.message_type_datasource.name
#     node_datasource                  = module.node_datasource.name
#     sub_field_datasource             = module.sub_field_datasource.name
#     templates_path                   = "${path.module}/files/response-template.vtl"
#     tenant_datasource                = module.tenant_datasource.name
#     validate_function_datasource     = module.validate_function_datasource.name
#   }
# }

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

resource "aws_appsync_resolver" "create_change_notification" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "CreateChangeNotification"
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

resource "aws_appsync_resolver" "list_keys" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "ListKeys"
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

## ChangeNotification
resource "aws_appsync_resolver" "change_notification_tenant" {
  api_id            = aws_appsync_graphql_api.echostream.id
  data_source       = module.appsync_datasource_.name
  field             = "tenant"
  request_template  = file("${path.module}/files/batch-invoke.vtl")
  response_template = file("${path.module}/files/response-template.vtl")
  type              = "ChangeNotification"
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