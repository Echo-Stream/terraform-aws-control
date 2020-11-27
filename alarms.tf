module "alarms" {
  lambdas = {
    appsync_kms_key_datasource               = module.appsync_kms_key_datasource.name
    appsync_tenant_datasource                = module.appsync_tenant_datasource.name
    app_cognito_pre_authentication           = module.app_cognito_pre_authentication.name
    app_cognito_pre_token_generation         = module.app_cognito_pre_token_generation.name
    appsync_edge_datasource                  = module.appsync_edge_datasource.name
    ui_cognito_post_signup                   = module.ui_cognito_post_signup.name
    ui_cognito_pre_authentication            = module.ui_cognito_pre_authentication.name
    ui_cognito_pre_signup                    = module.ui_cognito_pre_signup.name
    ui_cognito_pre_token_generation          = module.ui_cognito_pre_token_generation.name
    validate_function                        = module.validate_function.name
    appsync_message_type_datasource          = module.appsync_message_type_datasource.name
    appsync_app_datasource                   = module.appsync_app_datasource.name
    appsync_node_datasource                  = module.appsync_node_datasource.name
    appsync_sub_field_datasource             = module.appsync_sub_field_datasource.name
    appsync_large_message_storage_datasource = module.appsync_large_message_storage_datasource.name
    appsync_validate_function_datasource     = module.appsync_validate_function_datasource.name
    appsync_subscription_datasource          = module.appsync_subscription_datasource.name
    purge_tenants                            = module.purge_tenants.name
    graph_table_dynamodb_trigger             = module.graph_table_dynamodb_trigger.name
    graph_table_manage_users                 = module.graph_table_manage_users.name
    graph_table_manage_resource_policies     = module.graph_table_manage_resource_policies.name
    graph_table_manage_queues                = module.graph_table_manage_queues.name
    graph_table_manage_apps                  = module.graph_table_manage_apps.name
    graph_table_tenant_stream_handler        = module.graph_table_tenant_stream_handler.name
    graph_table_manage_message_types         = module.graph_table_manage_message_types.name
    graph_table_manage_nodes                 = module.graph_table_manage_nodes.name
    graph_table_manage_tenants               = module.graph_table_manage_tenants.name
    graph_table_manage_edges                 = module.graph_table_manage_edges.name
    graph_table_manage_kms_keys              = module.graph_table_manage_kms_keys.name

  }
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
  tags          = local.tags
  source        = "./_modules/lambda-alarms"
}