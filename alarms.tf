locals {
  lambdas = toset([
    module.appsync_kms_key_datasource.name,
    module.appsync_tenant_datasource.name,
    # module.app_cognito_pre_authentication.name,
    # module.app_cognito_pre_token_generation.name,
    module.appsync_edge_datasource.name,
    module.control_alert_handler.name,
    module.control_clickup_integration.name,
    # module.ui_cognito_post_signup.name,
    # module.ui_cognito_pre_authentication.name,
    # module.ui_cognito_pre_signup.name,
    # module.ui_cognito_pre_token_generation.name,
    module.validate_function.name,
    module.appsync_message_type_datasource.name,
    module.appsync_app_datasource.name,
    module.appsync_node_datasource.name,
    module.appsync_sub_field_datasource.name,
    module.appsync_large_message_storage_datasource.name,
    module.appsync_validate_function_datasource.name,
    module.appsync_subscription_datasource.name,
    module.purge_tenants.name,
    module.log_retention.name,
    module.graph_table_dynamodb_trigger.name,
    module.graph_table_manage_users.name,
    module.graph_table_manage_resource_policies.name,
    module.graph_table_manage_queues.name,
    module.graph_table_manage_apps.name,
    module.graph_table_tenant_stream_handler.name,
    module.graph_table_manage_message_types.name,
    module.graph_table_manage_nodes.name,
    module.graph_table_manage_tenants.name,
    module.graph_table_manage_edges.name,
    module.graph_table_manage_kms_keys.name,
  ])
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each            = local.lambdas
  alarm_name          = "lambda/errors/${each.value}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  actions_enabled     = "true"

  dimensions = {
    FunctionName = each.key
  }

  alarm_actions     = [aws_sns_topic.alerts.arn]
  alarm_description = "Monitors ${each.key} lambda errors"
  tags              = local.tags
}