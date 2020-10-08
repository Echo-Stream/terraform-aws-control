locals {
  aws_cli_command = "~/bin/aws"

  log_bucket = module.log_bucket.id

  artifacts_bucket            = "hl7-ninja-artifacts-${local.current_region}"
  lambda_dead_letter_arn      = aws_sns_topic.lambda_dead_letter.arn
  lambda_env_vars_kms_key_arn = aws_kms_key.lambda_environment_variables.arn

  artifacts_prefix = {
    lambda  = "${var.hl7_ninja_version}/lambda"
    appsync = "${var.hl7_ninja_version}/appsync"
    frontend = "${var.hl7_ninja_version}/frontend"
  }

  lambda_functions_keys = {
    app_cognito_pre_authentication    = "${local.artifacts_prefix["lambda"]}/app-cognito-pre-authentication.zip"
    app_cognito_pre_token_generation  = "${local.artifacts_prefix["lambda"]}/app-cognito-pre-token-generation.zip"
    appsync_edge_datasource           = "${local.artifacts_prefix["lambda"]}/appsync-edge-datasource.zip"
    appsync_tenant_datasource         = "${local.artifacts_prefix["lambda"]}/appsync-tenant-datasource.zip"
    appsync_kms_key_datasource        = "${local.artifacts_prefix["lambda"]}/appsync-kms-key-datasource.zip"
    graph_table_dynamodb_trigger      = "${local.artifacts_prefix["lambda"]}/graph-table-dynamodb-trigger.zip"
    graph_table_manage_apps           = "${local.artifacts_prefix["lambda"]}/graph-table-manage-apps.zip"
    graph_table_manage_queues         = "${local.artifacts_prefix["lambda"]}/graph-table-manage-queues.zip"
    graph_table_manage_users          = "${local.artifacts_prefix["lambda"]}/graph-table-manage-users.zip"
    graph_table_put_app_policies      = "${local.artifacts_prefix["lambda"]}/graph-table-put-app-policies.zip"
    ninja_tools_layer                 = "${local.artifacts_prefix["lambda"]}/ninja-tools-layer.zip"
    ui_cognito_post_signup            = "${local.artifacts_prefix["lambda"]}/ui-cognito-post-signup.zip"
    ui_cognito_pre_authentication     = "${local.artifacts_prefix["lambda"]}/ui-cognito-pre-authentication.zip"
    ui_cognito_pre_signup             = "${local.artifacts_prefix["lambda"]}/ui-cognito-pre-signup.zip"
    ui_cognito_pre_token_generation   = "${local.artifacts_prefix["lambda"]}/ui-cognito-pre-token-generation.zip"
    process_audit_record              = "${local.artifacts_prefix["lambda"]}/process-audit-record.zip"
    validate_function                 = "${local.artifacts_prefix["lambda"]}/validate-function.zip"
    graph_table_tenant_stream_handler = "${local.artifacts_prefix["lambda"]}/graph-table-tenant-stream-handler.zip"
    graph_table_manage_tenants        = "${local.artifacts_prefix["lambda"]}/graph-table-manage-tenants.zip"
    graph_table_manage_message_types  = "${local.artifacts_prefix["lambda"]}/graph-table-manage-message-types.zip"
    appsync_message_type_datasource   = "${local.artifacts_prefix["lambda"]}/appsync-message-type-datasource.zip"
  }

  current_region = data.aws_region.current.name

  tags = {
    Terraform   = "true"
    App         = "hl7-ninja"
    Environment = var.environment_prefix
  }
}
