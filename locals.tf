locals {
  region_keys = concat(
    [data.aws_region.current.name],
    local.non_control_regions
  )
  app_userpool_ids = jsonencode(
    zipmap(
      local.region_keys,
      concat(
        [module.app_cognito_pool_control.userpool_id],
        local.regional_app_userpool_ids,
      )
    )
  )

  app_userpool_client_ids = jsonencode(
    zipmap(
      local.region_keys,
      concat(
        [module.app_cognito_pool_control.client_id],
        local.regional_app_userpool_client_ids,
      )
    )
  )

  appsync_api_ids = jsonencode(
    zipmap(
      local.region_keys,
      concat(
        [aws_appsync_graphql_api.echostream.id],
        local.regional_appsync_api_ids,
      )
    )
  )

  appsync_custom_url = format("https://%s/graphql", aws_acm_certificate.regional_api[data.aws_region.current.name].domain_name)
  artifacts_sns_arn  = "arn:aws:sns:${data.aws_region.current.name}:${local.artifacts_account_id}:echostream-artifacts-${data.aws_region.current.name}_${replace(var.echostream_version, ".", "-")}"

  artifacts = {
    appsync        = "${var.echostream_version}/appsync"
    control_lambda = "${var.echostream_version}/lambda/control"
    echocore       = "${var.echostream_version}/lambda/layer/echocore.zip"
    functions      = "${var.echostream_version}/functions"
    glue = {
      audit_records_etl = "${var.echostream_version}/glue/audit-records-etl.py"
    }
    lambda_layer  = "${var.echostream_version}/lambda/layer"
    message_types = "${var.echostream_version}/message-types"
    reactjs       = "${var.echostream_version}/ui/app"
    tenant_lambda = "${var.echostream_version}/lambda/tenant"
  }

  artifacts_account_id     = "226390263822"                                               # echostream-artifacts
  artifacts_bucket         = "echostream-artifacts-${data.aws_region.current.name}"       # artifacts bucket name with region
  artifacts_bucket_prefix  = "echostream-artifacts"                                       # artifacts bucket name without region
  audit_firehose_log_group = "/aws/kinesisfirehose/${var.resource_prefix}-audit-firehose" # log group name for audit-firehose
  awssdkpandas_layer       = "arn:aws:lambda:${data.aws_region.current.name}:336392948345:layer:AWSSDKPandas-Python39:5"

  cost_and_usage_export_name  = "CostAndUsage"
  lambda_dead_letter_arn      = module.lambda_underpin_control.dead_letter_arn
  lambda_env_vars_kms_key_arn = module.lambda_underpin_control.kms_key_arn
  lambda_runtime              = "python3.9"

  lambda_functions_keys = {
    app_api_cognito_pre_authentication = "${local.artifacts["control_lambda"]}/app-api-cognito-pre-authentication.zip"
    appsync_datasource                 = "${local.artifacts["control_lambda"]}/appsync-datasource.zip"
    deployment_handler                 = "${local.artifacts["control_lambda"]}/deployment-handler.zip"
    graph_table_dynamodb_trigger       = "${local.artifacts["control_lambda"]}/graph-table-dynamodb-trigger.zip"
    graph_table_system_stream_handler  = "${local.artifacts["control_lambda"]}/graph-table-system-stream-handler.zip"
    graph_table_tenant_stream_handler  = "${local.artifacts["control_lambda"]}/graph-table-tenant-stream-handler.zip"
    managed_app_registration           = "${local.artifacts["control_lambda"]}/managed-app-registration.zip"
    paddle_webhooks                    = "${local.artifacts["control_lambda"]}/paddle-webhooks.zip"
    rebuild_notifications              = "${local.artifacts["control_lambda"]}/rebuild-notifications.zip"
    ui_cognito_post_confirmation       = "${local.artifacts["control_lambda"]}/ui-cognito-post-confirmation.zip"
    ui_cognito_pre_authentication      = "${local.artifacts["control_lambda"]}/ui-cognito-pre-authentication.zip"
    ui_cognito_pre_signup              = "${local.artifacts["control_lambda"]}/ui-cognito-pre-signup.zip"
  }

  lambda_layer_keys = {
    echocore = "${local.artifacts["lambda_layer"]}/echocore.json"
  }

  log_bucket          = module.log_bucket.id
  non_control_regions = sort(setsubtract(var.tenant_regions, [data.aws_region.current.name]))
  # Ensure that tenant_regions include the control region
  tenant_regions = sort(setunion(var.tenant_regions, [data.aws_region.current.name]))

  tags = merge({
    app         = "echostream"
    environment = var.resource_prefix
    terraform   = "true"
    version     = var.echostream_version
  }, var.tags)
}
