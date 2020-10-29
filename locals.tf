resource "random_uuid" "for_jwk" {}

resource "random_string" "for_jwk" {
  length  = 64
  special = true
}

locals {
  aws_cli_command = "~/bin/aws"

  log_bucket = module.log_bucket.id

  lambda_dead_letter_arn      = aws_sns_topic.lambda_dead_letter.arn
  lambda_env_vars_kms_key_arn = aws_kms_key.lambda_environment_variables.arn
  domain                      = "${var.environment_prefix}.${var.domain_name}"

  artifacts_bucket        = "echostream-artifacts-${local.current_region}"
  artifacts_bucket_prefix = "echostream-artifacts"
  artifacts_account_id    = "672550935748"
  artifacts = {
    lambda                 = "${var.echostream_version}/lambda/control"
    tenant_lambda          = "${var.echostream_version}/lambda/tenant"
    appsync                = "${var.echostream_version}/appsync"
    frontend               = "${var.echostream_version}/frontend"
    message_types          = "${var.echostream_version}/message-types"
    hl7_mllp_inbound_node  = "${local.artifacts_account_id}.dkr.ecr.us-east-1.amazonaws.com/hl7-mllp-inbound-node"
    hl7_mllp_outbound_node = "${local.artifacts_account_id}.dkr.ecr.us-east-1.amazonaws.com/hl7-mllp-outbound-node"
  }

  lambda_functions_keys = {
    app_cognito_pre_authentication           = "${local.artifacts["lambda"]}/app-cognito-pre-authentication.zip"
    app_cognito_pre_token_generation         = "${local.artifacts["lambda"]}/app-cognito-pre-token-generation.zip"
    appsync_edge_datasource                  = "${local.artifacts["lambda"]}/appsync-edge-datasource.zip"
    appsync_tenant_datasource                = "${local.artifacts["lambda"]}/appsync-tenant-datasource.zip"
    appsync_kms_key_datasource               = "${local.artifacts["lambda"]}/appsync-kms-key-datasource.zip"
    graph_table_dynamodb_trigger             = "${local.artifacts["lambda"]}/graph-table-dynamodb-trigger.zip"
    graph_table_manage_apps                  = "${local.artifacts["lambda"]}/graph-table-manage-apps.zip"
    graph_table_manage_queues                = "${local.artifacts["lambda"]}/graph-table-manage-queues.zip"
    graph_table_manage_users                 = "${local.artifacts["lambda"]}/graph-table-manage-users.zip"
    graph_table_manage_resource_policies     = "${local.artifacts["lambda"]}/graph-table-manage-resource-policies.zip"
    ui_cognito_post_signup                   = "${local.artifacts["lambda"]}/ui-cognito-post-signup.zip"
    ui_cognito_pre_authentication            = "${local.artifacts["lambda"]}/ui-cognito-pre-authentication.zip"
    ui_cognito_pre_signup                    = "${local.artifacts["lambda"]}/ui-cognito-pre-signup.zip"
    ui_cognito_pre_token_generation          = "${local.artifacts["lambda"]}/ui-cognito-pre-token-generation.zip"
    process_audit_record                     = "${local.artifacts["lambda"]}/process-audit-record.zip"
    validate_function                        = "${local.artifacts["lambda"]}/validate-function.zip"
    graph_table_tenant_stream_handler        = "${local.artifacts["lambda"]}/graph-table-tenant-stream-handler.zip"
    graph_table_manage_tenants               = "${local.artifacts["lambda"]}/graph-table-manage-tenants.zip"
    graph_table_manage_message_types         = "${local.artifacts["lambda"]}/graph-table-manage-message-types.zip"
    appsync_message_type_datasource          = "${local.artifacts["lambda"]}/appsync-message-type-datasource.zip"
    deployment_handler                       = "${local.artifacts["lambda"]}/deployment-handler.zip"
    appsync_app_datasource                   = "${local.artifacts["lambda"]}/appsync-app-datasource.zip"
    appsync_node_datasource                  = "${local.artifacts["lambda"]}/appsync-node-datasource.zip"
    appsync_sub_field_datasource             = "${local.artifacts["lambda"]}/appsync-sub-field-datasource.zip"
    graph_table_manage_nodes                 = "${local.artifacts["lambda"]}/graph-table-manage-nodes.zip"
    appsync_large_message_storage_datasource = "${local.artifacts["lambda"]}/appsync-large-message-storage-datasource.zip"
    appsync_validate_function_datasource     = "${local.artifacts["lambda"]}/appsync-validate-function-datasource.zip"
    appsync_subscription_datasource          = "${local.artifacts["lambda"]}/appsync-subscription-datasource.zip"
    graph_table_manage_edges                 = "${local.artifacts["lambda"]}/graph-table-manage-edges.zip"
    graph_table_manage_kms_keys              = "${local.artifacts["lambda"]}/graph-table-manage-kms-keys.zip"
    purge_tenants                            = "${local.artifacts["lambda"]}/purge-tenants.zip"

    router_node = "${local.artifacts["tenant_lambda"]}/router-node.zip"
    trans_node  = "${local.artifacts["tenant_lambda"]}/trans-node.zip"
  }

  internal_appsync_role_names = jsonencode([
    "${var.environment_prefix}-appsync-edge-datasource",
    "${var.environment_prefix}-appsync-message-type-datasource",
    "${var.environment_prefix}-appsync-tenant-datasource",
    "${var.environment_prefix}-appsync-kms-key-datasource",
    "${var.environment_prefix}-appsync-app-datasource",
    "${var.environment_prefix}-appsync-node-datasource",
    "${var.environment_prefix}-appsync-sub-field-datasource",
    "${var.environment_prefix}-appsync-large-message-storage-datasource",
    "${var.environment_prefix}-appsync-validate-function-datasource",
    "${var.environment_prefix}-appsync-subscription-datasource",
    "${var.environment_prefix}-graph-table-dynamodb-trigger",
    "${var.environment_prefix}-graph-table-manage-apps",
    "${var.environment_prefix}-graph-table-manage-queues",
    "${var.environment_prefix}-graph-table-manage-users",
    "${var.environment_prefix}-graph-table-manage-resource-policies",
    "${var.environment_prefix}-graph-table-tenant-stream-handler",
    "${var.environment_prefix}-graph-table-manage-tenants",
    "${var.environment_prefix}-graph-table-manage-message-types",
    "${var.environment_prefix}-graph-table-manage-nodes",
    "${var.environment_prefix}-graph-table-manage-edges",
    "${var.environment_prefix}-graph-table-manage-kms-keys",
  ])

  current_region = data.aws_region.current.name

  id_token_key = <<-EOT
                    {
                      "kty": "oct",
                      "kid": "${random_uuid.for_jwk.result}"
                      "use": "sig",
                      "alg": "HS256",
                      "k": "${base64encode(random_string.for_jwk.result)}"
                    }
                  EOT


  tags = {
    terraform   = "true"
    app         = "echostream"
    environment = var.environment_prefix
  }
}
