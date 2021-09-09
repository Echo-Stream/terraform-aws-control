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

  artifacts_account_id    = "226390263822" # echostream-artifacts
  artifacts_bucket        = "echostream-artifacts-${local.current_region}"
  artifacts_bucket_prefix = "echostream-artifacts"

  aws_cli_command = "~/bin/aws"
  current_region  = data.aws_region.current.name
  domain          = "${var.resource_prefix}.${var.domain_name}"

  id_token_key = <<-EOT
                    {
                      "kty": "oct",
                      "kid": "${random_uuid.for_jwk.result}",
                      "use": "sig",
                      "alg": "HS256",
                      "k": "${base64encode(random_string.for_jwk.result)}"
                    }
                  EOT

  common_lambda_environment_variables = {
    ALARM_SNS_TOPIC               = aws_sns_topic.alarms.arn
    ALERT_SNS_TOPIC               = aws_sns_topic.alerts.arn
    API_ID                        = aws_appsync_graphql_api.echostream.id
    APPSYNC_ENDPOINT              = aws_appsync_graphql_api.echostream.uris["GRAPHQL"]
    ARTIFACTS_BUCKET              = local.artifacts_bucket_prefix
    AUDIT_FIREHOSE                = aws_kinesis_firehose_delivery_stream.process_audit_record_firehose.name
    CLOUDFRONT_DISTRIBUTION_ID    = aws_cloudfront_distribution.webapp.id
    CONTROL_REGION                = local.current_region
    DYNAMODB_TABLE                = module.graph_table.name
    ECHOSTREAM_VERSION            = var.echostream_version
    ENVIRONMENT                   = var.resource_prefix
    HIGH_THROUGHPUT_QUEUE_REGIONS = ""
    ID_TOKEN_KEY                  = local.id_token_key
    INTERNAL_NODE_CODE            = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/internal-node.zip\"}"
    INTERNAL_NODE_ROLE            = aws_iam_role.tenant_function.name
    REGION                        = var.region
    SNS_TOPIC_ARN                 = aws_sns_topic.ci_cd_errors.arn
    SYSTEM_SQS_QUEUE              = aws_sqs_queue.system_sqs_queue.id
    TENANT_DB_STREAM_HANDLER      = "${var.resource_prefix}-graph-table-tenant-stream-handler"
    UPDATE_CODE_ROLE              = aws_iam_role.update_code.arn
    VALIDATOR_CODE                = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/validator.zip\"}"
    VALIDATOR_ROLE                = aws_iam_role.validator.arn
  }

  lambda_dead_letter_arn      = aws_sns_topic.lambda_dead_letter.arn
  lambda_env_vars_kms_key_arn = aws_kms_key.lambda_environment_variables.arn

  lambda_functions_keys = {
    app_api_cognito_pre_authentication = "${local.artifacts["lambda"]}/app-api-cognito-pre-authentication.zip"
    app_cognito_pre_token_generation   = "${local.artifacts["lambda"]}/app-cognito-pre-token-generation.zip"
    appsync_datasource                 = "${local.artifacts["lambda"]}/appsync-datasource.zip"
    control_alert_handler              = "${local.artifacts["lambda"]}/control-alert-handler.zip"
    control_clickup_integration        = "${local.artifacts["lambda"]}/control-clickup-integration.zip"
    deployment_handler                 = "${local.artifacts["lambda"]}/deployment-handler.zip"
    graph_table_dynamodb_trigger       = "${local.artifacts["lambda"]}/graph-table-dynamodb-trigger.zip"
    graph_table_tenant_stream_handler  = "${local.artifacts["lambda"]}/graph-table-tenant-stream-handler.zip"
    log_retention                      = "${local.artifacts["lambda"]}/log-retention.zip"
    process_audit_record               = "${local.artifacts["lambda"]}/process-audit-record.zip"
    ui_cognito_post_confirmation       = "${local.artifacts["lambda"]}/ui-cognito-post-confirmation.zip"
    ui_cognito_pre_authentication      = "${local.artifacts["lambda"]}/ui-cognito-pre-authentication.zip"
    ui_cognito_pre_signup              = "${local.artifacts["lambda"]}/ui-cognito-pre-signup.zip"
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
