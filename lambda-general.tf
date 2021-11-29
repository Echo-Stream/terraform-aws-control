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
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-log-retention"
  policy      = data.aws_iam_policy_document.log_retention.json
}

module "log_retention" {
  description     = "set log group retention to 7 days"
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

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["log_retention"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 60
  version       = "3.0.17"
}


resource "aws_cloudwatch_event_rule" "log_retention" {
  name                = "${var.resource_prefix}-log-retention"
  description         = "set log group retention to 7 days daily"
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