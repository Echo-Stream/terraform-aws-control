######################
##  log-retention   ##
######################
data "aws_iam_policy_document" "log_retention" {
  statement {
    actions = [
      "logs:DescribeLogGroups"
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
    ]

    sid = "ListLogGroups"
  }

  statement {
    actions = [
      "logs:PutRetentionPolicy"
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*",
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
  version       = "4.0.1"
}


resource "aws_cloudwatch_event_rule" "log_retention" {
  name                = "${var.resource_prefix}-log-retention"
  description         = "Set log group retention to 7 days daily"
  schedule_expression = "cron(0 10 * * ? *)"
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "log_retention" {
  arn       = module.log_retention.arn
  rule      = aws_cloudwatch_event_rule.log_retention.name
  target_id = "${var.resource_prefix}-log-retention"
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
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.cost_and_usage.arn,
      "${aws_s3_bucket.cost_and_usage.arn}/*"
    ]

    sid = "AllowReadAndWriteToCostAndUsageBucket"
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
  statement {
    actions = [
      "ses:GetTemplate",
      "ses:ListTemplates"
    ]

    resources = [
      "*"
    ]

    sid = "SESRead"
  }


  statement {
    actions = [
      "ses:SendEmail",
    ]

    resources = [
      aws_ses_configuration_set.email_errors.arn,
      data.aws_ses_email_identity.support.arn,
    ]

    sid = "SESSendEmail"
  }

  statement {
    actions = [
      "ses:SendTemplatedEmail",
    ]

    resources = [
      aws_ses_configuration_set.email_errors.arn,
      data.aws_ses_email_identity.support.arn,
      aws_ses_template.managed_app_cloud_init_notify.arn,
    ]

    sid = "SESSendTemplatedEmail"
  }
}

resource "aws_iam_policy" "managed_app_cloud_init" {
  description = "IAM permissions required for managed-app-cloud-init lambda"
  name        = "${var.resource_prefix}-managed-app-cloud-init"
  policy      = data.aws_iam_policy_document.managed_app_cloud_init.json
}

module "managed_app_cloud_init" {
  description           = "Updates Glue db with managed app instance details and notifies Tenant owners by an email"
  dead_letter_arn       = local.lambda_dead_letter_arn
  environment_variables = local.common_lambda_environment_variables
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  layers                = ["arn:aws:lambda:${data.aws_region.current.name}:336392948345:layer:AWSDataWrangler-Python39:9"]
  memory_size           = 1536
  name                  = "${var.resource_prefix}-managed-app-cloud-init"

  policy_arns = [
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.managed_app_cloud_init.arn,
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["managed_app_cloud_init"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 60
  version       = "4.0.1"
}

resource "aws_lambda_event_source_mapping" "managed_app_cloud_init" {
  event_source_arn = aws_sqs_queue.managed_app_cloud_init.arn
  function_name    = module.managed_app_cloud_init.name
}