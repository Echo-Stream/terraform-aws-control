resource "aws_s3_bucket" "lambda_environment" {
  bucket = "${var.resource_prefix}-lambda-environment"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_environment" {
  bucket = aws_s3_bucket.lambda_environment.id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    id     = "remove-aborted-uploads"
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "lambda_environment" {
  bucket        = aws_s3_bucket.lambda_environment.id
  target_bucket = local.log_bucket
  target_prefix = "${var.resource_prefix}-lambda-environment/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_environment" {
  bucket = aws_s3_bucket.lambda_environment.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_environment" {
  bucket                  = aws_s3_bucket.lambda_environment.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "lambda_environment" {
  statement {
    actions = [
      "s3:*",
    ]
    condition {
      test = "Bool"
      values = [
        "false",
      ]
      variable = "aws:SecureTransport"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
    resources = [
      aws_s3_bucket.lambda_environment.arn,
      "${aws_s3_bucket.lambda_environment.arn}/*",
    ]
    sid = "DenyUnsecuredTransport"
  }
}

resource "aws_s3_bucket_policy" "lambda_environment" {
  bucket = aws_s3_bucket.lambda_environment.id
  policy = data.aws_iam_policy_document.lambda_environment.json
}

resource "aws_s3_object" "lambda_environment" {
  bucket = aws_s3_bucket.lambda_environment.id
  content = jsonencode(
    {
      ALARM_TOPIC                                = aws_sns_topic.alarms.arn
      API_ID                                     = aws_appsync_graphql_api.echostream.id
      API_USER_POOL_CLIENT_ID                    = aws_cognito_user_pool_client.echostream_api_userpool_client.id
      API_USER_POOL_ID                           = aws_cognito_user_pool.echostream_api.id
      APP_USER_POOL_IDS                          = local.app_userpool_ids
      APP_USER_POOL_CLIENT_IDS                   = local.app_userpool_client_ids
      APPSYNC_ENDPOINT                           = local.appsync_custom_url
      ARTIFACTS_BUCKET                           = local.artifacts_bucket_prefix
      ATHENA_WORKGROUP                           = aws_athena_workgroup.echostream_athena.name
      AUDITOR_CODE                               = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/auditor.zip\"}"
      AUDIT_FIREHOSE_LOG_GROUP                   = local.audit_firehose_log_group
      AUDIT_FIREHOSE_ROLE                        = aws_iam_role.audit_firehose.arn
      AUDITOR_ROLE                               = aws_iam_role.auditor.arn
      BILLING_DATABASE                           = aws_glue_catalog_database.billing.name
      BILLING_ENABLED                            = var.billing_enabled ? "True" : "False"
      BULK_DATA_AWS_ACCESS_KEY_ID                = aws_iam_access_key.presign_bulk_data.id
      BULK_DATA_AWS_SECRET_ACCESS_KEY            = aws_iam_access_key.presign_bulk_data.secret
      BULK_DATA_IAM_USER                         = aws_iam_user.presign_bulk_data.arn
      COST_AND_USAGE_BUCKET                      = aws_s3_bucket.cost_and_usage.id
      DYNAMODB_TABLE                             = module.graph_table.name
      ECHOSTREAM_VERSION                         = var.echostream_version
      ENVIRONMENT                                = var.resource_prefix
      INTERNAL_NODE_CODE                         = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/internal-node.zip\"}"
      INTERNAL_NODE_ROLE                         = aws_iam_role.internal_node.arn
      INVITE_USER_SES_TEMPLATE                   = aws_ses_template.invite_user.name
      LAMBDA_RUNTIME                             = local.lambda_runtime
      MANAGED_APP_CLOUD_INIT_NOTIFY_SES_TEMPLATE = aws_ses_template.managed_app_cloud_init_notify.name
      MANAGED_APP_CLOUD_INIT_QUEUE               = aws_sqs_queue.managed_app_cloud_init.url
      NOTIFY_USER_SES_TEMPLATE                   = aws_ses_template.notify_user.name
      PADDLE_API_KEY_SECRET_ARN                  = local.paddle_api_key_secret_arn
      PADDLE_BASE_URL                            = local.paddle_base_url
      PADDLE_MINIMUM_BILLING_AMOUNT              = var.paddle_minimum_billing_amount
      PADDLE_PRICE_IDS                           = jsonencode(var.paddle_price_ids)
      PADDLE_PRODUCT_IDS                         = jsonencode(var.paddle_product_ids)
      REBUILD_NOTIFICATION_QUEUE                 = aws_sqs_queue.rebuild_notifications.url
      RECORD_CLOUDWATCH_ALARM_QUEUE              = aws_sqs_queue.record_cloudwatch_alarm.url
      RECORD_TENANT_QUEUE                        = aws_sqs_queue.record_tenant.url
      REGION                                     = data.aws_region.current.name
      REGIONAL_APPSYNC_ENDPOINTS                 = local.regional_appsync_endpoints
      REMOTE_APP_ROLE                            = aws_iam_role.remote_app.arn
      REMOVE_USER_SES_TEMPLATE                   = aws_ses_template.remove_user.name
      SSM_SERVICE_ROLE                           = aws_iam_role.managed_app.name
      SYSTEM_SES_EMAIL                           = data.aws_ses_email_identity.support.email
      SYSTEM_SQS_QUEUE                           = aws_sqs_queue.system_sqs_queue.id
      TENANT_CREATED_SES_TEMPLATE                = aws_ses_template.tenant_created.name
      TENANT_DB_STREAM_HANDLER                   = "${var.resource_prefix}-graph-table-tenant-stream-handler"
      TENANT_DB_STREAM_HANDLER_ROLE              = module.graph_table_tenant_stream_handler.role_arn
      TENANT_DELETED_SES_TEMPLATE                = aws_ses_template.tenant_deleted.name
      TENANT_ERRORED_SES_TEMPLATE                = aws_ses_template.tenant_errored.name
      TENANT_REGIONS                             = jsonencode(local.tenant_regions)
      UI_USER_POOL_ID                            = aws_cognito_user_pool.echostream_ui.id
      USAGE_MULTIPLE                             = local.usage_multiple
      VALIDATOR_CODE                             = "{\"S3Key\": \"${local.artifacts["tenant_lambda"]}/validator.zip\"}"
      VALIDATOR_ROLE                             = aws_iam_role.validator.arn
      WEBSUB_NODE_ROLE                           = aws_iam_role.websub_node.arn
    }
  )
  content_type = "application/json"
  key          = "lambda-environment.json"
}

locals {
  # Common environment variables for lambdas that use echo-tools library
  common_lambda_environment_variables = {
    CONTROL_REGION     = data.aws_region.current.name
    ENVIRONMENT_BUCKET = aws_s3_bucket.lambda_environment.bucket
    ENVIRONMENT_KEY    = aws_s3_object.lambda_environment.key
  }
}

data "aws_iam_policy_document" "read_lambda_environment" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    effect = "Allow"
    resources = [
      aws_s3_bucket.lambda_environment.arn,
    ]
    sid = "ListBucket"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]
    effect = "Allow"
    resources = [
      aws_s3_object.lambda_environment.arn,
    ]
    sid = "GetObject"
  }
}

resource "aws_iam_policy" "read_lambda_environment" {
  description = "IAM permissions required for reading the lambda environment file"

  name   = "${var.resource_prefix}-read-lambda-environment"
  policy = data.aws_iam_policy_document.read_lambda_environment.json
}

