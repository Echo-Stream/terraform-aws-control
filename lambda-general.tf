######################
##  log-retention   ##
######################
data "aws_iam_policy_document" "log_retention" {
  statement {
    actions = [
      "logs:DescribeLogGroups"
    ]

    resources = [
      "arn:aws:logs:${var.region}:${var.allowed_account_id}:*",
    ]

    sid = "ListLogGroups"
  }

  statement {
    actions = [
      "logs:PutRetentionPolicy"
    ]

    resources = [
      "arn:aws:logs:${var.region}:${var.allowed_account_id}:log-group:*",
    ]

    sid = "SetRetention"
  }
}

resource "aws_iam_policy" "log_retention" {
  description = "IAM permissions required for log-retention lambda"

  name   = "${var.resource_prefix}-log-retention"
  policy = data.aws_iam_policy_document.log_retention.json
}

module "log_retention" {
  description     = "Set log group retention to 7 days"
  dead_letter_arn = local.lambda_dead_letter_arn
  environment_variables = {
    ENVIRONMENT = var.resource_prefix
  }
  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 128
  name        = "${var.resource_prefix}-log-retention"

  policy_arns = [
    aws_iam_policy.log_retention.arn,
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["log_retention"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 60
  version       = "4.0.0"
}


resource "aws_cloudwatch_event_rule" "log_retention" {
  name                = "${var.resource_prefix}-log-retention"
  description         = "Set log group retention to 7 days daily"
  schedule_expression = "cron(0 10 * * ? *)"
}

resource "aws_cloudwatch_event_target" "log_retention" {
  rule      = aws_cloudwatch_event_rule.log_retention.name
  target_id = "${var.resource_prefix}-log-retention"
  arn       = module.log_retention.arn
}

resource "aws_lambda_permission" "log_retention" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.log_retention.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.log_retention.arn
}

###############################
##  managed-app-cloud-init   ##
###############################
data "aws_iam_policy_document" "managed_app_cloud_init" {
  statement {
    actions = [
      "logs:DescribeLogGroups"
    ]

    resources = [
      "arn:aws:logs:${var.region}:${var.allowed_account_id}:*",
    ]

    sid = "ListLogGroups"
  }

  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage*",
      "sqs:DeleteMessage*",
      "sqs:GetQueueAttributes"
    ]

    resources = [aws_sqs_queue.managed_app_cloud_init.arn]

    sid = "ManagedAppCloudInitQueuesAccess"
  }
}

resource "aws_iam_policy" "managed_app_cloud_init" {
  description = "IAM permissions required for managed-app-cloud-init lambda"
  name        = "${var.resource_prefix}-managed-app-cloud-init"
  policy      = data.aws_iam_policy_document.managed_app_cloud_init.json
}

module "managed_app_cloud_init" {
  description     = "It updates the billing DB with managed app instance details and notifies Tenant owners by an email"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    ENVIRONMENT = var.resource_prefix
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 128
  name        = "${var.resource_prefix}-managed-app-cloud-init"

  policy_arns = [
    aws_iam_policy.managed_app_cloud_init.arn,
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["managed_app_cloud_init"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 60
  version       = "4.0.0"
}

resource "aws_lambda_event_source_mapping" "managed_app_cloud_init" {
  event_source_arn = aws_sqs_queue.managed_app_cloud_init.arn
  function_name    = module.managed_app_cloud_init.name
}