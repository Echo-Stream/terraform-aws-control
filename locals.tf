locals {
  app_user_pool_ids = jsonencode(
    {
      us-east-1 = module.app_cognito_pool_us_east_1.0.userpool_id
      us-east-2 = module.app_cognito_pool_us_east_2.0.userpool_id
      us-west-1 = module.app_cognito_pool_us_west_1.0.userpool_id
      us-west-2 = module.app_cognito_pool_us_west_2.0.userpool_id
    }
  )

  app_user_pool_client_ids = jsonencode(
    {
      us-east-1 = module.app_cognito_pool_us_east_1.0.client_id
      us-east-2 = module.app_cognito_pool_us_east_2.0.client_id
      us-west-1 = module.app_cognito_pool_us_west_1.0.client_id
      us-west-2 = module.app_cognito_pool_us_west_2.0.client_id
    }
  )

  appsync_api_ids = jsonencode(
    {
      us-east-1 = aws_appsync_graphql_api.echostream.id
      us-east-2 = module.appsync_us_east_2.0.api_id
      us-west-1 = module.appsync_us_west_1.0.api_id
      us-west-2 = module.appsync_us_west_2.0.api_id
    }
  )

  appsync_custom_url = format("https://%s/graphql", lookup(local.regional_apis["domains"], var.region, ""))
  artifacts_sns_arn  = "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:echostream-artifacts-${local.current_region}_${replace(var.echostream_version, ".", "-")}"

  artifacts = {
    appsync   = "${var.echostream_version}/appsync"
    functions = "${var.echostream_version}/functions"
    glue = {
      audit_records_etl = "${var.echostream_version}/glue/audit-records-etl.py"
    }
    lambda        = "${var.echostream_version}/lambda/control"
    message_types = "${var.echostream_version}/message-types"
    reactjs       = "${var.echostream_version}/ui/app"
    tenant_lambda = "${var.echostream_version}/lambda/tenant"
  }

  artifacts_account_id     = "226390263822"                                               # echostream-artifacts
  artifacts_bucket         = "echostream-artifacts-${local.current_region}"               # artifacts bucket name with region
  artifacts_bucket_prefix  = "echostream-artifacts"                                       # artifacts bucket name without region
  audit_firehose_log_group = "/aws/kinesisfirehose/${var.resource_prefix}-audit-firehose" # log group name for audit-firehose
  current_account_id       = data.aws_caller_identity.current.account_id                  # current or control account_id
  current_region           = data.aws_region.current.name                                 # current region or control region

  # Common environment variables for lambdas that use echo-tools library
  common_lambda_environment_variables = {
    ALARM_TOPIC                                 = aws_sns_topic.alarms.arn
    API_ID                                      = aws_appsync_graphql_api.echostream.id
    API_USER_POOL_CLIENT_ID                     = aws_cognito_user_pool_client.echostream_api_userpool_client.id
    API_USER_POOL_ID                            = aws_cognito_user_pool.echostream_api.id
    APP_USER_POOL_IDS                           = local.app_user_pool_ids
    APP_USER_POOL_CLIENT_IDS                    = local.app_user_pool_client_ids
    APPSYNC_API_IDS                             = local.appsync_api_ids
    APPSYNC_ENDPOINT                            = local.appsync_custom_url
    ARTIFACTS_BUCKET                            = local.artifacts_bucket_prefix
    AUDITOR_CODE                                = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/auditor.zip\"}"
    AUDIT_FIREHOSE_LOG_GROUP                    = local.audit_firehose_log_group
    AUDIT_FIREHOSE_ROLE                         = aws_iam_role.audit_firehose.arn
    AUDITOR_ROLE                                = aws_iam_role.auditor.arn
    BULK_DATA_AWS_ACCESS_KEY_ID                 = aws_iam_access_key.presign_bulk_data.id
    BULK_DATA_AWS_SECRET_ACCESS_KEY             = aws_iam_access_key.presign_bulk_data.secret
    BULK_DATA_IAM_USER                          = aws_iam_user.presign_bulk_data.arn
    CI_CD_TOPIC_ARN                             = aws_sns_topic.ci_cd_errors.arn
    CLOUDFRONT_DISTRIBUTION_ID_DOCS             = aws_cloudfront_distribution.docs.id
    CLOUDFRONT_DISTRIBUTION_ID_WEBAPP           = aws_cloudfront_distribution.webapp.id
    CONTROL_REGION                              = local.current_region
    COST_AND_USAGE_BUCKET                       = aws_s3_bucket.cost_and_usage.id
    DYNAMODB_TABLE                              = module.graph_table.name
    ECHOSTREAM_VERSION                          = var.echostream_version
    ENVIRONMENT                                 = var.resource_prefix
    HIGH_THROUGHPUT_QUEUE_REGIONS               = "[\"us-east-1\", \"us-east-2\", \"us-west-2\", \"eu-west-1\"]"
    INTERNAL_NODE_CODE                          = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/internal-node.zip\"}"
    INTERNAL_NODE_ROLE                          = aws_iam_role.internal_node.arn
    INVITE_USER_SES_TEMPLATE                    = aws_ses_template.invite_user.name
    MANAGED_APP_CLOUD_INIT_NOTIFY_SES_TEMPLATE  = aws_ses_template.managed_app_cloud_init_notify.name
    MANAGED_APP_CLOUD_INIT_QUEUE                = aws_sqs_queue.managed_app_cloud_init.url
    NOTIFY_USER_SES_TEMPLATE                    = aws_ses_template.notify_user.name
    REBUILD_NOTIFICATION_QUEUE                  = aws_sqs_queue.rebuild_notifications.url
    REGION                                      = var.region
    REGIONAL_APPSYNC_ENDPOINTS                  = local.regional_appsync_endpoints
    REMOTE_APP_ROLE                             = aws_iam_role.remote_app.arn
    REMOVE_USER_SES_TEMPLATE                    = aws_ses_template.remove_user.name
    SSM_SERVICE_ROLE                            = aws_iam_role.managed_app.name
    SYSTEM_SES_EMAIL                            = data.aws_ses_email_identity.support.email
    SYSTEM_SQS_QUEUE                            = aws_sqs_queue.system_sqs_queue.id
    TENANT_CREATED_SES_TEMPLATE                 = aws_ses_template.tenant_created.name
    TENANT_DB_STREAM_HANDLER                    = "${var.resource_prefix}-graph-table-tenant-stream-handler"
    TENANT_DB_STREAM_HANDLER_ROLE               = module.graph_table_tenant_stream_handler.role_arn
    TENANT_DELETED_SES_TEMPLATE                 = aws_ses_template.tenant_deleted.name
    TENANT_ERRORED_SES_TEMPLATE                 = aws_ses_template.tenant_errored.name
    TENANT_REGIONS                              = jsonencode(var.tenant_regions)
    UI_USER_POOL_ID                             = aws_cognito_user_pool.echostream_ui.id
    UPDATE_CODE_ROLE                            = aws_iam_role.update_code.arn
    VALIDATOR_CODE                              = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/validator.zip\"}"
    VALIDATOR_ROLE                              = aws_iam_role.validator.arn
  }

  lambda_dead_letter_arn      = aws_sns_topic.lambda_dead_letter.arn
  lambda_env_vars_kms_key_arn = aws_kms_key.lambda_environment_variables.arn
  lambda_runtime              = "python3.9"

  lambda_functions_keys = {
    app_api_cognito_pre_authentication = "${local.artifacts["lambda"]}/app-api-cognito-pre-authentication.zip"
    appsync_datasource                 = "${local.artifacts["lambda"]}/appsync-datasource.zip"
    deployment_handler                 = "${local.artifacts["lambda"]}/deployment-handler.zip"
    graph_table_dynamodb_trigger       = "${local.artifacts["lambda"]}/graph-table-dynamodb-trigger.zip"
    graph_table_system_stream_handler  = "${local.artifacts["lambda"]}/graph-table-system-stream-handler.zip"
    graph_table_tenant_stream_handler  = "${local.artifacts["lambda"]}/graph-table-tenant-stream-handler.zip"
    log_retention                      = "${local.artifacts["lambda"]}/log-retention.zip"
    rebuild_notifications              = "${local.artifacts["lambda"]}/rebuild-notifications.zip"
    ui_cognito_post_confirmation       = "${local.artifacts["lambda"]}/ui-cognito-post-confirmation.zip"
    ui_cognito_pre_authentication      = "${local.artifacts["lambda"]}/ui-cognito-pre-authentication.zip"
    ui_cognito_pre_signup              = "${local.artifacts["lambda"]}/ui-cognito-pre-signup.zip"

    ## Billing
    managed_app_cloud_init = "${local.artifacts["lambda"]}/managed-app-cloud-init.zip"
  }

  log_bucket     = module.log_bucket.id
  regional_appsync_endpoints = jsonencode(
    {
      us-east-1 = format("https://%s/graphql", lookup(local.regional_apis["domains"], "us-east-1", ""))
      us-east-2 = format("https://%s/graphql", lookup(local.regional_apis["domains"], "us-east-2", ""))
      us-west-1 = format("https://%s/graphql", lookup(local.regional_apis["domains"], "us-west-1", ""))
      us-west-2 = format("https://%s/graphql", lookup(local.regional_apis["domains"], "us-west-2", ""))
    }
  )
  regions        = concat(var.tenant_regions, [var.region]) # Tenant + Control Regions

  tags = merge({
    app         = "echostream"
    environment = var.resource_prefix
    terraform   = "true"
    version     = var.echostream_version
  }, var.tags)
}
