##########################
##  Deployment handler  ##
##########################
data "aws_iam_policy_document" "deployment_handler" {
  statement {
    actions = [
      "iam:CreateRole",
      "iam:PassRole",
    ]

    resources = ["*"]

    sid = "IAMPermissions"
  }
  statement {
    actions = [
      "lambda:CreateFunction",
      "lambda:GetFunction*",
      "lambda:GetLayerVersion",
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
      "lambda:PublishLayerVersion",
      "lambda:PublishVersion",
      "lambda:TagResource",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaDeployAccess"
  }

  statement {
    actions = [
      "appsync:StartSchemaCreation",
      "appsync:GetSchemaCreationStatus",
      "appsync:*GraphqlApi",
    ]

    resources = [
      "*"
    ]

    sid = "UpdateSchema"
  }

  statement {
    actions = [
      "sns:Subscribe"
    ]

    resources = [
      local.artifacts_sns_arn
    ]

    sid = "RegionalArtifactsSNSTopicSubscription"
  }

  statement {
    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = [
      aws_cloudfront_distribution.webapp.arn,
      aws_cloudfront_distribution.docs.arn
    ]

    sid = "InvalidateCloudfrontObjects"
  }

  statement {
    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.ci_cd_errors.arn
    ]

    sid = "snsPublish"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:PutRetentionPolicy"
    ]

    resources = [
      "*",
    ]

    sid = "AllowWritingErrorEvents"
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


resource "aws_iam_policy" "deployment_handler" {
  description = "IAM permissions required for deployment-handler lambda"

  name   = "${var.resource_prefix}-deployment-handler"
  policy = data.aws_iam_policy_document.deployment_handler.json
}

module "deployment_handler" {
  description = "Does appropriate deployments by getting notified from Artifacts bucket"
  environment_variables = merge(
    local.common_lambda_environment_variables,
    {
      APPSYNC_API_IDS                   = local.appsync_api_ids
      CI_CD_TOPIC_ARN                   = aws_sns_topic.ci_cd_errors.arn
      CLOUDFRONT_DISTRIBUTION_ID_DOCS   = aws_cloudfront_distribution.docs.id
      CLOUDFRONT_DISTRIBUTION_ID_WEBAPP = aws_cloudfront_distribution.webapp.id
    },
  )
  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  layers          = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size     = 1536
  name            = "${var.resource_prefix}-deployment-handler"

  policy_arns = [
    aws_iam_policy.artifacts_bucket_read.arn,
    aws_iam_policy.deployment_handler.arn,
    aws_iam_policy.ecr_read.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.graph_ddb_write.arn,
    aws_iam_policy.read_lambda_environment.arn,
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["deployment_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 900
  version       = "4.0.2"
}

resource "aws_lambda_permission" "deployment_handler" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.deployment_handler.name
  principal     = "sns.amazonaws.com"
  source_arn    = local.artifacts_sns_arn
}

resource "aws_sns_topic_subscription" "artifacts" {
  topic_arn = local.artifacts_sns_arn
  protocol  = "lambda"
  endpoint  = module.deployment_handler.arn
}

#############################
##  Rebuild Notifications  ##
#############################
data "aws_iam_policy_document" "rebuild_notifications" {
  statement {
    actions = [
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
    ]

    resources = [
      "${module.graph_table.arn}",
    ]

    sid = "TableScanAccess"
  }

  statement {
    actions = [
      "lambda:CreateFunction",
      "lambda:GetFunction*",
      "lambda:GetLayerVersion",
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
      "lambda:PublishLayerVersion",
      "lambda:PublishVersion",
      "lambda:TagResource",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaDeployAccess"
  }

  statement {
    actions = [
      "sqs:ReceiveMessage*",
      "sqs:DeleteMessage*",
      "sqs:GetQueueAttributes"
    ]

    resources = [aws_sqs_queue.rebuild_notifications.arn]

    sid = "EdgeQueuesAccess"
  }

  statement {
    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.auditor.arn,
      aws_iam_role.internal_node.arn,
      aws_iam_role.validator.arn,
    ]

    sid = "AllowInternalPassRole"
  }
}


resource "aws_iam_policy" "rebuild_notifications" {
  description = "IAM permissions required for deployment-handler lambda"

  name   = "${var.resource_prefix}-rebuild-notifications"
  policy = data.aws_iam_policy_document.rebuild_notifications.json
}

module "rebuild_notifications" {
  description           = "Notify Echo Objects"
  environment_variables = local.common_lambda_environment_variables
  dead_letter_arn       = local.lambda_dead_letter_arn
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  layers                = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size           = 1536
  name                  = "${var.resource_prefix}-rebuild-notifications"

  policy_arns = [
    aws_iam_policy.artifacts_bucket_read.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.read_lambda_environment.arn,
    aws_iam_policy.rebuild_notifications.arn,
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["rebuild_notifications"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 600
  version       = "4.0.2"
}

resource "aws_sqs_queue" "rebuild_notifications" {
  content_based_deduplication = "true"
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
  name                        = "${var.resource_prefix}-rebuild-notifications.fifo"
  tags                        = local.tags
  visibility_timeout_seconds  = 3600
}

##########################################
##  Rebuild Notifications State Machine ##
##########################################
resource "aws_iam_role" "rebuild_notifications_state_machine" {
  assume_role_policy = data.aws_iam_policy_document.state_machine_assume_role.json
  name               = "${var.resource_prefix}-rebuild-notifications-state-machine"
  tags               = local.tags
}

data "aws_iam_policy_document" "rebuild_notifications_state_machine" {
  statement {

    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [module.rebuild_notifications.arn]
    sid       = "InvokeLambda"
  }


  statement {
    effect = "Allow"

    actions = [
      "states:StartExecution",
    ]

    resources = ["arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.resource_prefix}-rebuild-notifications"]

    sid = "StateMachineAccess"
  }

  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:DescribeLogGroups",
      "logs:DescribeResourcePolicies",
      "logs:GetLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:UpdateLogDelivery",
    ]

    resources = [
      "*"
    ]

    sid = "AllowWritingErrorEvents"
  }
}

resource "aws_iam_role_policy" "rebuild_notifications_state_machine" {
  policy = data.aws_iam_policy_document.rebuild_notifications_state_machine.json
  role   = aws_iam_role.rebuild_notifications_state_machine.id
}

resource "aws_cloudwatch_log_group" "rebuild_notifications_state_machine" {
  name              = "/aws/statemachine/${var.resource_prefix}-rebuild-notifications"
  retention_in_days = 7
  tags              = local.tags
}

resource "aws_sfn_state_machine" "rebuild_notifications" {
  definition = templatefile(
    "${path.module}/templates/rebuild-notifications-state-machine.json",
    {
      function_arn          = module.rebuild_notifications.arn
      sleep_time_in_seconds = 60
      my_arn                = "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.resource_prefix}-rebuild-notifications"
    }
  )
  name     = "${var.resource_prefix}-rebuild-notifications"
  role_arn = aws_iam_role.rebuild_notifications_state_machine.arn
  logging_configuration {
    level           = "ERROR"
    log_destination = "${aws_cloudwatch_log_group.rebuild_notifications_state_machine.arn}:*"
  }
  tags = local.tags
}

data "archive_file" "start_rebuild_notifications_state_machine" {
  type        = "zip"
  output_path = "${path.module}/start-rebuild-notifications-state-machine.zip"

  source {
    content = templatefile(
      "${path.module}/scripts/start-rebuild-notifications-state-machine.py",
      {
        state_machine_arn = aws_sfn_state_machine.rebuild_notifications.arn
      }
    )
    filename = "function.py"
  }
}

data "aws_iam_policy_document" "start_rebuild_notifications_state_machine" {
  statement {
    actions = [
      "states:ListExecutions",
      "states:StartExecution",
    ]
    resources = [
      aws_sfn_state_machine.rebuild_notifications.arn,
    ]
    sid = "SfnAccess"
  }
}

resource "aws_iam_role" "start_rebuild_notifications_state_machine" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-start-rebuild-notifications-state-machine"
    policy = data.aws_iam_policy_document.start_rebuild_notifications_state_machine.json
  }
  managed_policy_arns = [data.aws_iam_policy.aws_lambda_basic_execution_role.arn]
  name                = "${var.resource_prefix}-start-rebuild-notifications-state-machine"
  tags                = local.tags
}

resource "aws_lambda_function" "start_rebuild_notifications_state_machine" {
  description      = "Edge Lambda that returns an environment specific config for reactjs application"
  filename         = data.archive_file.start_rebuild_notifications_state_machine.output_path
  function_name    = "${var.resource_prefix}-start-rebuild-notifications-state-machine"
  handler          = "function.lambda_handler"
  publish          = true
  role             = aws_iam_role.start_rebuild_notifications_state_machine.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.start_rebuild_notifications_state_machine.output_base64sha256
  tags             = local.tags
  timeout          = 300
}

resource "aws_lambda_permission" "start_rebuild_notifications_state_machine" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_rebuild_notifications_state_machine.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.rebuild_notification_failures.arn
}

resource "aws_sns_topic_subscription" "rebuild_notification_failures" {
  topic_arn = aws_sns_topic.rebuild_notification_failures.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.start_rebuild_notifications_state_machine.arn
}

resource "aws_lambda_invocation" "start_rebuild_notifications_state_machine" {
  function_name = aws_lambda_function.start_rebuild_notifications_state_machine.function_name
  input         = "{}"
}
