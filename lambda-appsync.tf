###########################
##  appsync--datasource  ##
###########################
data "aws_iam_policy_document" "appsync_datasource" {
  statement {
    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
    ]

    resources = [
      "arn:aws:sqs:*:${local.current_account_id}:db-stream*",
      "arn:aws:sqs:*:${local.current_account_id}:dead-letter*.fifo",
      "arn:aws:sqs:*:${local.current_account_id}:edge*.fifo",
    ]

    sid = "ManageQueues"
  }

  statement {
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:TagResource",
      "sns:UnSubscribe"
    ]

    resources = [
      "arn:aws:sns:*:${local.current_account_id}:alert*",
      "arn:aws:sns:*:${local.current_account_id}:timer*"
    ]

    sid = "ManageSNSTopics"
  }

  statement {
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketNotification",
      "s3:PutBucketLogging",
      "s3:PutBucketNotification",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutEncryptionConfiguration",
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
      "*"
    ]

    sid = "PassRoleAll"
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

  statement {
    actions = [
      "kms:CreateAlias",
      "kms:CreateGrant",
      "kms:CreateKey",
      "kms:Decrypt",
      "kms:DeleteAlias",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:GetKeyPolicy",
      "kms:PutKeyPolicy",
      "kms:RetireGrant",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource"
    ]

    resources = [
      "*"
    ]

    sid = "ManageKMS"
  }

  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:FilterLogEvents"
    ]

    resources = [
      "*",
    ]

    sid = "DescribeAllLogGroups"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DeleteRetentionPolicy",
      "logs:DeleteSubscriptionFilter",
      "logs:PutRetentionPolicy",
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      "arn:aws:logs:*:${local.current_account_id}:log-group:/aws/lambda/*",
      "arn:aws:logs:*:${local.current_account_id}:log-group:echostream/managed-app/*:log-stream:*"
    ]

    sid = "ManageCWLogs"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DeleteLogStream"
    ]

    resources = [
      "arn:aws:logs:*:${local.current_account_id}:log-group:/aws/kinesisfirehose/${var.resource_prefix}-audit-firehose:log-stream:*"
    ]

    sid = "ManageLogStreams"
  }

  statement {
    actions = [
      "firehose:CreateDeliveryStream",
      "firehose:DeleteDeliveryStream"
    ]

    resources = [
      "arn:aws:firehose:*:${local.current_account_id}:deliverystream/${var.resource_prefix}-tenant-*"
    ]

    sid = "ManageFirehoseStreams"
  }

  statement {
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:PutMetricAlarm"
    ]

    resources = [
      "arn:aws:cloudwatch:*:${local.current_account_id}:alarm:TENANT~*"
    ]

    sid = "ManageAlarms"
  }

  statement {
    actions = [
      "lambda:*",
    ]

    resources = [
      "*"
    ]

    sid = "FullAccessLambda"
  }

  statement {
    effect = "Deny"
    actions = [
      "lambda:*",
    ]

    resources = [
      aws_lambda_function.edge_config.arn,
      module.appsync_datasource.arn,
      module.deployment_handler.arn,
      module.graph_table_dynamodb_trigger.arn,
      module.graph_table_system_stream_handler.arn,
      module.log_retention.arn,
      module.rebuild_notifications.arn,
      module.ui_cognito_post_confirmation.arn,
      module.ui_cognito_pre_authentication.arn,
      module.ui_cognito_pre_signup.arn,
    ]

    sid = "AllowOnlyTenantStreamHandlerAccess"
  }

  statement {
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:TagResource"
    ]

    resources = [
      "arn:aws:dynamodb:*:${local.current_account_id}:table/${var.resource_prefix}-tenant-*"
    ]

    sid = "TenantDDB"
  }

  statement {
    actions = [
      "events:TagResource",
      "events:PutRule",
      "events:DeleteRule",
      "events:PutTargets",
      "events:RemoveTargets"
    ]

    resources = [
      "arn:aws:events:*:${local.current_account_id}:rule/timer*"
    ]

    sid = "EventsAccess"
  }

  statement {
    actions = [
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminSetUserPassword"
    ]

    resources = [
      aws_cognito_user_pool.echostream_api.arn
    ]

    sid = "CognitoIDPAccess"
  }

  statement {
    actions = [
      "ecr:DescribeImages"
    ]

    resources = [
      "arn:aws:ecr:*:*:repository/*"
    ]

    sid = "ECRDescribeAll"
  }

  statement {
    actions = [
      "ssm:AddTagsToResource",
      "ssm:DeregisterManagedInstance",
      "ssm:DescribeInstance*"
    ]

    resources = [
      "arn:aws:ssm:*:${local.current_account_id}:*"
    ]

    sid = "SSM"
  }

  statement {
    actions = [
      "ssm:CreateActivation",
      "ssm:AddTagsToResource"
    ]

    resources = [
      aws_iam_role.managed_app.arn
    ]

    sid = "SSM2"
  }


}

resource "aws_iam_policy" "appsync_datasource" {
  description = "IAM permissions required for appsync-datasource lambda"

  name   = "${var.resource_prefix}-appsync-datasource"
  policy = data.aws_iam_policy_document.appsync_datasource.json
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
      SSM_SERVICE_ROLE                = aws_iam_role.managed_app.name
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
    aws_iam_policy.artifacts_bucket_read.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.graph_ddb_write.arn,
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.18"
}