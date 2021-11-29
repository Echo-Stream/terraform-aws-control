##################################
## graph-table-dynamodb-trigger ##
##################################
data "aws_iam_policy_document" "graph_table_dynamodb_trigger" {
  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      "arn:aws:sqs:*:*:db-stream*",
      aws_sqs_queue.system_sqs_queue.arn
    ]

    sid = "DeliverMessageToQueues"
  }

  statement {
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams",
      "dynamodb:PutItem"
    ]

    resources = [
      module.graph_table.stream_arn,
    ]

    sid = "AllowReadingFromStreams"
  }

  statement {
    actions = [
      "dynamodb:Query",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "WriteAccesstoTable"
  }
}

resource "aws_iam_policy" "graph_table_dynamodb_trigger" {
  description = "IAM permissions required for graph-table-dynamodb-trigger"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-graph-table-dynamodb-trigger"
  policy      = data.aws_iam_policy_document.graph_table_dynamodb_trigger.json
}

module "graph_table_dynamodb_trigger" {
  description           = "Routes Dynamodb Stream events to the correct Lambda Functions"
  dead_letter_arn       = local.lambda_dead_letter_arn
  environment_variables = local.common_lambda_environment_variables

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
  name        = "${var.resource_prefix}-graph-table-dynamodb-trigger"

  policy_arns = [
    aws_iam_policy.graph_table_dynamodb_trigger.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_dynamodb_trigger"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.17"
}

resource "aws_lambda_event_source_mapping" "graph_table_dynamodb_trigger" {
  batch_size        = "1"
  event_source_arn  = module.graph_table.stream_arn
  function_name     = module.graph_table_dynamodb_trigger.name
  starting_position = "LATEST"
}

resource "aws_cloudwatch_log_subscription_filter" "graph_table_dynamodb_trigger" {
  name            = "${var.resource_prefix}-graph-table-dynamodb-trigger"
  log_group_name  = module.graph_table_dynamodb_trigger.log_group_name
  filter_pattern  = "ERROR -USERERROR"
  destination_arn = module.control_alert_handler.arn
}


resource "aws_iam_role" "managed_app" {
  description        = "Enable AWS Systems Manager service core functionality"
  name               = "${var.resource_prefix}-managed-app"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.managed_app.json
  tags               = local.tags
}

data "aws_iam_policy_document" "managed_app" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "ssm.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "managed_app_customer_policy" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
    ]

    resources = [
      "arn:aws:ecr:*:*:repository/*"
    ]

    sid = "EcrAccess"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*"
    ]

    sid = "LogsAccess"
  }

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = [aws_sns_topic.managed_app_cloud_init.arn]

    sid = "PublishToSNS"
  }
}

resource "aws_iam_policy" "managed_app_customer_policy" {
  description = "IAM permissions required for manage apps ssm"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.managed_app_customer_policy.json
}

resource "aws_iam_role_policy_attachment" "managed_app_customer_policy" {
  policy_arn = aws_iam_policy.managed_app_customer_policy.arn
  role       = aws_iam_role.managed_app.name
}

resource "aws_iam_role_policy_attachment" "managed_app" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.managed_app.name
}

resource "aws_iam_role_policy_attachment" "manage_apps_ssm_directory_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
  role       = aws_iam_role.managed_app.name
}

#######################################
## graph-table-tenant-stream-handler ##
#######################################
data "aws_iam_policy_document" "graph_table_tenant_stream_handler" {
  statement {
    actions = [
      "sqs:DeleteQueue",
    ]

    resources = [
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:edge*.fifo",
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:db-stream*.fifo"
    ]

    sid = "DeleteQueue"
  }

  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.rebuild_notifications.arn
    ]

    sid = "SendMessageToRebuildNotificationQueue"
  }
  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "appsync:GraphQL",
      "appsync:GetGraphqlApi"
    ]

    resources = [
      aws_appsync_graphql_api.echostream.arn,
    ]

    sid = "AppsyncAccess"
  }

  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]

    resources = [
      "arn:aws:sqs:*:*:*db-stream*.fifo",
      aws_sqs_queue.system_sqs_queue.arn
    ]

    sid = "PrerequisitesForQueueTrigger"
  }

  statement {
    actions = [
      "ses:GetTemplate",
      "ses:ListTemplates",
      "ses:SendEmail",
      "ses:SendTemplatedEmail",
    ]

    resources = [
      "*"
    ]

    sid = "SESAccess"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteSubscriptionFilter",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminUserGlobalSignOut",
      "cognito-idp:ListUsers",
    ]

    resources = [aws_cognito_user_pool.echostream_api.arn,
      aws_cognito_user_pool.echostream_ui.arn,
    aws_cognito_user_pool.echostream_api.arn]

    sid = "AdminGetUser"
  }


  statement {
    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:ListGrants",
      "kms:ListResourceGrants",
      "kms:RetireGrant",
      "kms:RevokeGrant",
      "kms:ScheduleKeyDeletion",
    ]

    resources = ["*"]

    sid = "KMSPermissions"
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
    ]

    resources = [
      "arn:aws:ecr:${local.current_region}:${local.artifacts_account_id}:repository/*"
    ]

    sid = "ECRAccess"
  }

  statement {
    actions = [
      "lambda:DeleteEventSourceMapping",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:DeleteLayerVersion",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetLayerVersion",
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions",
      "lambda:PublishLayerVersion",
      "lambda:UpdateFunctionConfiguration",
      "lambda:Invoke",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaAllAccess"
  }


  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${local.artifacts["lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${local.artifacts["lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${local.artifacts["lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${local.artifacts["tenant_lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${local.artifacts["tenant_lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${local.artifacts["tenant_lambda"]}/*",
    ]

    sid = "GetArtifacts"
  }

  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      aws_iam_role.internal_node.arn
    ]

    sid = "TenantFunctionRoleIAM"
  }

  statement {
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "firehose:PutRecordBatch",
    ]

    resources = [
      aws_kinesis_firehose_delivery_stream.process_audit_record_firehose.arn,
      "arn:aws:firehose:*:${data.aws_caller_identity.current.account_id}:deliverystream/${var.resource_prefix}-audit-records"
    ]

    sid = "PutRecordBatch"
  }
}

resource "aws_iam_policy" "graph_table_tenant_stream_handler" {
  description = "IAM permissions required for graph-table-tenant-stream-handler"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-graph-table-tenant-stream-handler"
  policy      = data.aws_iam_policy_document.graph_table_tenant_stream_handler.json
}

module "graph_table_tenant_stream_handler" {
  description     = "Delegates calls to handling lambda functions in EchoStream Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn
  environment_variables = merge(local.common_lambda_environment_variables,
  { LOGGING_LEVEL = "DEBUG" })
  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.resource_prefix}-graph-table-tenant-stream-handler"

  policy_arns = [
    aws_iam_policy.graph_table_tenant_stream_handler.arn,
    aws_iam_policy.additional_ddb_policy.arn,
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_tenant_stream_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.15"
}

#######################################
## graph-table-system-stream-handler ##
#######################################
data "aws_iam_policy_document" "graph_table_system_stream_handler" {

  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "appsync:GraphQL",
      "appsync:GetGraphqlApi"
    ]

    resources = [
      aws_appsync_graphql_api.echostream.arn,
    ]

    sid = "AppsyncAccess"
  }

  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.system_sqs_queue.arn
    ]

    sid = "PrerequisitesForQueueTrigger"
  }

  statement {
    actions = [
      "ses:GetTemplate",
      "ses:ListTemplates",
      "ses:SendEmail",
      "ses:SendTemplatedEmail",
    ]

    resources = [
      "*"
    ]

    sid = "SESAccess"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteSubscriptionFilter",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminUserGlobalSignOut",
      "cognito-idp:ListUsers",
    ]

    resources = [
      #aws_cognito_user_pool.echostream_apps.arn,
      aws_cognito_user_pool.echostream_ui.arn,
    aws_cognito_user_pool.echostream_api.arn]

    sid = "AdminGetUser"
  }


  statement {
    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:ListGrants",
      "kms:ListResourceGrants",
      "kms:RetireGrant",
      "kms:RevokeGrant",
      "kms:ScheduleKeyDeletion",
    ]

    resources = ["*"]

    sid = "KMSPermissions"
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
    ]

    resources = [
      "arn:aws:ecr:${local.current_region}:${local.artifacts_account_id}:repository/*"
    ]

    sid = "ECRAccess"
  }

  statement {
    actions = [
      "lambda:DeleteEventSourceMapping",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:DeleteLayerVersion",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetLayerVersion",
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions",
      "lambda:PublishLayerVersion",
      "lambda:UpdateFunctionConfiguration",
      "lambda:Invoke",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaAllAccess"
  }


  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${local.artifacts["lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${local.artifacts["lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${local.artifacts["lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${local.artifacts["tenant_lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${local.artifacts["tenant_lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${local.artifacts["tenant_lambda"]}/*",
    ]

    sid = "GetArtifacts"
  }

  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      aws_iam_role.internal_node.arn
    ]

    sid = "TenantFunctionRoleIAM"
  }

  statement {
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.rebuild_notifications.arn
    ]

    sid = "SendMessageToRebuildNotificationQueue"
  }
}

resource "aws_iam_policy" "graph_table_system_stream_handler" {
  description = "IAM permissions required for graph-table-system-stream-handler"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-graph-table-system-stream-handler"
  policy      = data.aws_iam_policy_document.graph_table_system_stream_handler.json
}

module "graph_table_system_stream_handler" {
  description     = "Handles system-related DB changes"
  dead_letter_arn = local.lambda_dead_letter_arn
  environment_variables = merge(local.common_lambda_environment_variables,
  { LOGGING_LEVEL = "DEBUG" })
  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.resource_prefix}-graph-table-system-stream-handler"

  policy_arns = [
    aws_iam_policy.graph_table_system_stream_handler.arn,
    aws_iam_policy.additional_ddb_policy.arn,
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_system_stream_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.17"
}

resource "aws_lambda_event_source_mapping" "graph_table_system_stream_handler" {
  function_name    = module.graph_table_system_stream_handler.arn
  event_source_arn = aws_sqs_queue.system_sqs_queue.arn
}