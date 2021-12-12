###########################
##  appsync--datasource  ##
###########################
data "aws_iam_policy_document" "appsync_datasource" {
  statement {
    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:TagQueue",
    ]

    resources = [
      "arn:aws:sqs:*:${local.current_account_id}:db-stream*",
      "arn:aws:sqs:*:${local.current_account_id}:dead-letter*.fifo",
      "arn:aws:sqs:*:${local.current_account_id}:edge*.fifo",
    ]

    sid = "CreateDeleteQueue"
  }

  statement {
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:TagResource"
    ]

    resources = [
      "arn:aws:sns:*:${local.current_account_id}:alert*"
    ]

    sid = "ReadWriteTopics"
  }

  statement {
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketLogging",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutLifecycleConfiguration",
    ]

    resources = [
      "arn:aws:s3:::${var.resource_prefix}-tenant-*",
    ]

    sid = "S3Access"
  }


  statement {
    actions = [
      "lambda:CreateEventSourceMapping",
      "lambda:DeleteEventSourceMapping",
    ]

    resources = [
      "arn:aws:lambda:*:${local.current_account_id}:event-source-mapping:*"
    ]

    sid = "LambdaEventSourceMappingAccess"
  }

  statement {
    actions = [
      "lambda:CreateEventSourceMapping",
    ]

    resources = [
      "*"
    ]

    sid = "CreateLambdaEventSourceMapping"
  }

  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      module.graph_table_system_stream_handler.role_arn
    ]

    sid = "PassRoleToSystemStreamHandler"
  }

  statement {
    actions = [
      "lambda:DeleteEventSourceMapping",
    ]

    resources = [
      "arn:aws:lambda:*:${local.current_account_id}:event-source-mapping:*"
    ]

    sid = "DeleteLambdaEventSourceMapping"
  }

  statement {
    actions = [
      "ses:SendEmail",
    ]

    resources = [
      aws_ses_configuration_set.email_errors.arn,
      aws_ses_email_identity.support.arn,
    ]

    sid = "SESSendEmail"
  }

  statement {
    actions = [
      "ses:SendTemplatedEmail",
    ]

    resources = [
      aws_ses_configuration_set.email_errors.arn,
      aws_ses_email_identity.support.arn,
      aws_ses_template.invite_user.arn,
      aws_ses_template.notify_user.arn,
      aws_ses_template.remove_user.arn,
    ]

    sid = "SESSendTemplatedEmail"
  }
}

resource "aws_iam_policy" "appsync_datasource" {
  description = "IAM permissions required for appsync-datasource lambda"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-appsync-datasource"
  policy      = data.aws_iam_policy_document.appsync_datasource.json
}

module "appsync_datasource" {
  description     = "The main datasource for the echo-stream API "
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = merge(local.common_lambda_environment_variables,
    {
      API_USER_POOL_CLIENT_ID         = aws_cognito_user_pool_client.echostream_api_userpool_client.id
      API_USER_POOL_ID                = aws_cognito_user_pool.echostream_api.id
      AUDIT_FIREHOSE_LOG_GROUP        = local.audit_firehose_log_group
      AUDIT_FIREHOSE_ROLE             = aws_iam_role.audit_firehose.arn
      BULK_DATA_AWS_ACCESS_KEY_ID     = aws_iam_access_key.presign_bulk_data.id
      BULK_DATA_AWS_SECRET_ACCESS_KEY = aws_iam_access_key.presign_bulk_data.secret
      BULK_DATA_IAM_USER              = aws_iam_user.presign_bulk_data.arn
      MANAGED_APP_CLOUD_INIT_TOPIC    = aws_sns_topic.managed_app_cloud_init.arn
      REMOTE_APP_ROLE                 = aws_iam_role.remote_app.arn
      SSM_SERVICE_ROLE                = "service-role/${aws_iam_role.managed_app.name}"
      TENANT_DB_STREAM_HANDLER_ROLE   = module.graph_table_tenant_stream_handler.role_arn
      UI_USER_POOL_ID                 = aws_cognito_user_pool.echostream_ui.id
    }
  )

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.resource_prefix}-appsync-datasource"

  policy_arns = [
    aws_iam_policy.appsync_datasource.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.graph_ddb_write.arn,
    #"arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.18"
}