locals {
  appsync_custom_url = "https://${var.api_domain_name}/graphql"
  artifacts_sns_arn       = "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:echostream-artifacts-${local.current_region}_${replace(var.echostream_version, ".", "-")}"

  artifacts = {
    appsync   = "${var.echostream_version}/appsync"
    functions = "${var.echostream_version}/functions"
    glue = {
      audit_records_etl = "${var.echostream_version}/glue/audit-records-etl.py"
    }
    lambda        = "${var.echostream_version}/lambda/control"
    message_types = "${var.echostream_version}/message-types"
    reactjs       = "${var.echostream_version}/reactjs"
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
    API_ID                        = aws_appsync_graphql_api.echostream.id
    APPSYNC_ENDPOINT              = local.appsync_custom_url
    ARTIFACTS_BUCKET              = local.artifacts_bucket_prefix
    CLOUDFRONT_DISTRIBUTION_ID    = aws_cloudfront_distribution.webapp.id
    CONTROL_REGION                = local.current_region
    DYNAMODB_TABLE                = module.graph_table.name
    ECHOSTREAM_VERSION            = var.echostream_version
    ENVIRONMENT                   = var.resource_prefix
    HIGH_THROUGHPUT_QUEUE_REGIONS = "[\"us-east-1\", \"us-east-2\", \"us-west-2\", \"eu-west-1\"]"
    INTERNAL_NODE_CODE            = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/internal-node.zip\"}"
    INTERNAL_NODE_ROLE            = aws_iam_role.internal_node.arn
    INVITE_USER_SES_TEMPLATE      = aws_ses_template.invite_user.name
    NOTIFY_USER_SES_TEMPLATE      = aws_ses_template.notify_user.name
    REBUILD_NOTIFICATION_QUEUE    = aws_sqs_queue.rebuild_notifications.url
    REGION                        = var.region
    REMOVE_USER_SES_TEMPLATE      = aws_ses_template.remove_user.name
    SNS_TOPIC_ARN                 = aws_sns_topic.ci_cd_errors.arn
    SYSTEM_SES_EMAIL              = var.ses_email_address
    SYSTEM_SQS_QUEUE              = aws_sqs_queue.system_sqs_queue.id
    TENANT_DB_STREAM_HANDLER      = "${var.resource_prefix}-graph-table-tenant-stream-handler"
    TENANT_REGIONS                = jsonencode(local.tenant_regions)
    UPDATE_CODE_ROLE              = aws_iam_role.update_code.arn
    VALIDATOR_CODE                = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/validator.zip\"}"
    VALIDATOR_ROLE                = aws_iam_role.validator.arn
  }

  lambda_dead_letter_arn      = aws_sns_topic.lambda_dead_letter.arn
  lambda_env_vars_kms_key_arn = aws_kms_key.lambda_environment_variables.arn

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
  }

  log_bucket             = module.log_bucket.id
  module_release_version = "0.0.3"                                    # this is used in workflows/publish.yml to release terraform module
  regions                = concat(local.tenant_regions, [var.region]) # Tenant + Control Regions
  tenant_regions         = split(",", var.tenant_regions)             # only Tenant regions

  tags = merge({
    app         = "echostream"
    environment = var.resource_prefix
    terraform   = "true"
    version     = var.echostream_version
  }, var.tags)
}
