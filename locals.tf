resource "random_uuid" "for_jwk" {}

resource "random_string" "for_jwk" {
  length  = 64
  special = true
}

locals {
  artifacts_sns_arn = "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:echostream-artifacts-${local.current_region}_${replace(var.echostream_version, ".", "-")}"
  artifacts = {
    #hl7_mllp_inbound_node  = "${local.artifacts_account_id}.dkr.ecr.us-east-1.amazonaws.com/hl7-mllp-inbound-node"
    #hl7_mllp_outbound_node = "${local.artifacts_account_id}.dkr.ecr.us-east-1.amazonaws.com/hl7-mllp-outbound-node"
    appsync  = "${var.echostream_version}/appsync"
    frontend = "${var.echostream_version}/frontend"
    glue = {
      audit_records_etl = "${var.echostream_version}/glue/audit-records-etl.py"
    }
    lambda        = "${var.echostream_version}/lambda/control"
    message_types = "${var.echostream_version}/message-types"
    tenant_lambda = "${var.echostream_version}/lambda/tenant"
  }

  artifacts_account_id    = "672550935748" # QuiNovas-MSP
  artifacts_bucket        = "echostream-artifacts-${local.current_region}"
  artifacts_bucket_prefix = "echostream-artifacts"
  aws_cli_command         = "~/bin/aws"
  current_region          = data.aws_region.current.name
  domain                  = "${var.resource_prefix}.${var.domain_name}"

  id_token_key = <<-EOT
                    {
                      "kty": "oct",
                      "kid": "${random_uuid.for_jwk.result}",
                      "use": "sig",
                      "alg": "HS256",
                      "k": "${base64encode(random_string.for_jwk.result)}"
                    }
                  EOT

  internal_appsync_role_names = jsonencode([
    "${var.resource_prefix}-appsync-app-datasource",
    "${var.resource_prefix}-appsync-edge-datasource",
    "${var.resource_prefix}-appsync-function-datasource",
    "${var.resource_prefix}-appsync-kms-key-datasource",
    "${var.resource_prefix}-appsync-large-message-storage-datasource",
    "${var.resource_prefix}-appsync-message-type-datasource",
    "${var.resource_prefix}-appsync-node-datasource",
    "${var.resource_prefix}-appsync-sub-field-datasource",
    "${var.resource_prefix}-appsync-subscription-datasource",
    "${var.resource_prefix}-appsync-tenant-datasource",
    "${var.resource_prefix}-appsync-validate-function-datasource",
    "${var.resource_prefix}-graph-table-dynamodb-trigger",
    "${var.resource_prefix}-graph-table-manage-apps",
    "${var.resource_prefix}-graph-table-manage-edges",
    "${var.resource_prefix}-graph-table-manage-functions",
    "${var.resource_prefix}-graph-table-manage-kms-keys",
    "${var.resource_prefix}-graph-table-manage-message-types",
    "${var.resource_prefix}-graph-table-manage-nodes",
    "${var.resource_prefix}-graph-table-manage-resource-policies",
    "${var.resource_prefix}-graph-table-manage-tenants",
    "${var.resource_prefix}-graph-table-manage-users",
    "${var.resource_prefix}-graph-table-tenant-stream-handler",
  ])

  lambda_dead_letter_arn      = aws_sns_topic.lambda_dead_letter.arn
  lambda_env_vars_kms_key_arn = aws_kms_key.lambda_environment_variables.arn

  lambda_functions_keys = {
    api_cognito_pre_authentication           = "${local.artifacts["lambda"]}/api-cognito-pre-authentication.zip"
    api_cognito_pre_token_generation         = "${local.artifacts["lambda"]}/api-cognito-pre-token-generation.zip"
    app_cognito_pre_authentication           = "${local.artifacts["lambda"]}/app-cognito-pre-authentication.zip"
    app_cognito_pre_token_generation         = "${local.artifacts["lambda"]}/app-cognito-pre-token-generation.zip"
    appsync_api_user_datasource              = "${local.artifacts["lambda"]}/appsync-api-user-datasource.zip"
    appsync_app_datasource                   = "${local.artifacts["lambda"]}/appsync-app-datasource.zip"
    appsync_edge_datasource                  = "${local.artifacts["lambda"]}/appsync-edge-datasource.zip"
    appsync_function_datasource              = "${local.artifacts["lambda"]}/appsync-function-datasource.zip"
    appsync_integrations_datasource          = "${local.artifacts["lambda"]}/appsync-integrations-datasource.zip"
    appsync_kms_key_datasource               = "${local.artifacts["lambda"]}/appsync-kms-key-datasource.zip"
    appsync_large_message_storage_datasource = "${local.artifacts["lambda"]}/appsync-large-message-storage-datasource.zip"
    appsync_message_type_datasource          = "${local.artifacts["lambda"]}/appsync-message-type-datasource.zip"
    appsync_node_datasource                  = "${local.artifacts["lambda"]}/appsync-node-datasource.zip"
    appsync_sub_field_datasource             = "${local.artifacts["lambda"]}/appsync-sub-field-datasource.zip"
    appsync_subscription_datasource          = "${local.artifacts["lambda"]}/appsync-subscription-datasource.zip"
    appsync_tenant_datasource                = "${local.artifacts["lambda"]}/appsync-tenant-datasource.zip"
    appsync_validate_function_datasource     = "${local.artifacts["lambda"]}/appsync-validate-function-datasource.zip"
    control_alert_handler                    = "${local.artifacts["lambda"]}/control-alert-handler.zip"
    control_clickup_integration              = "${local.artifacts["lambda"]}/control-clickup-integration.zip"
    deployment_handler                       = "${local.artifacts["lambda"]}/deployment-handler.zip"
    graph_table_dynamodb_trigger             = "${local.artifacts["lambda"]}/graph-table-dynamodb-trigger.zip"
    graph_table_manage_apps                  = "${local.artifacts["lambda"]}/graph-table-manage-apps.zip"
    graph_table_manage_authorizations        = "${local.artifacts["lambda"]}/graph-table-manage-authorizations.zip"
    graph_table_manage_edges                 = "${local.artifacts["lambda"]}/graph-table-manage-edges.zip"
    graph_table_manage_functions             = "${local.artifacts["lambda"]}/graph-table-manage-functions.zip"
    graph_table_manage_kms_keys              = "${local.artifacts["lambda"]}/graph-table-manage-kms-keys.zip"
    graph_table_manage_message_types         = "${local.artifacts["lambda"]}/graph-table-manage-message-types.zip"
    graph_table_manage_nodes                 = "${local.artifacts["lambda"]}/graph-table-manage-nodes.zip"
    graph_table_manage_resource_policies     = "${local.artifacts["lambda"]}/graph-table-manage-resource-policies.zip"
    graph_table_manage_tenants               = "${local.artifacts["lambda"]}/graph-table-manage-tenants.zip"
    graph_table_manage_users                 = "${local.artifacts["lambda"]}/graph-table-manage-users.zip"
    graph_table_tenant_stream_handler        = "${local.artifacts["lambda"]}/graph-table-tenant-stream-handler.zip"
    log_retention                            = "${local.artifacts["lambda"]}/log-retention.zip"
    node_error_publisher                     = "${local.artifacts["tenant_lambda"]}/node-error-publisher.zip"
    process_audit_record                     = "${local.artifacts["lambda"]}/process-audit-record.zip"
    purge_tenants                            = "${local.artifacts["lambda"]}/purge-tenants.zip"
    queue_alarm_publisher                    = "${local.artifacts["tenant_lambda"]}/queue-alarm-publisher.zip"
    router_node                              = "${local.artifacts["tenant_lambda"]}/router-node.zip"
    tenant_alert_publisher                   = "${local.artifacts["tenant_lambda"]}/tenant-alert-publisher.zip"
    trans_node                               = "${local.artifacts["tenant_lambda"]}/trans-node.zip"
    ui_cognito_post_signup                   = "${local.artifacts["lambda"]}/ui-cognito-post-signup.zip"
    ui_cognito_pre_authentication            = "${local.artifacts["lambda"]}/ui-cognito-pre-authentication.zip"
    ui_cognito_pre_signup                    = "${local.artifacts["lambda"]}/ui-cognito-pre-signup.zip"
    ui_cognito_pre_token_generation          = "${local.artifacts["lambda"]}/ui-cognito-pre-token-generation.zip"
    validate_function                        = "${local.artifacts["lambda"]}/validate-function.zip"
  }

  log_bucket = module.log_bucket.id
  regions    = concat(var.tenant_regions, [var.region])

  tags = merge({
    app         = "echostream"
    environment = var.resource_prefix
    terraform   = "true"
    version     = var.echostream_version
  }, var.tags)
}
