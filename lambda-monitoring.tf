###########################
## control-alert-handler ##
###########################
data "aws_iam_policy_document" "control_alert_handler" {
  statement {
    actions = [
      "lambda:Invoke",
    ]
    resources = [
      "*"
    ]

    sid = "LambdaInvoke"
  }

  statement {
    actions = [
      "sns:Publish",
    ]
    resources = [
      "*"
    ]

    sid = "SnsPublish"
  }
}

resource "aws_iam_policy" "control_alert_handler" {
  description = "IAM permissions required for control-alert-handler"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-control-alert-handler"
  policy      = data.aws_iam_policy_document.control_alert_handler.json
}

module "control_alert_handler" {
  description     = "Processes CW alarms and log subscriptions"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    ALERT_TOPIC  = aws_sns_topic.alarms.arn
    ENVIRONMENT  = var.resource_prefix
    INTEGRATIONS = "[\"${module.control_clickup_integration.arn}\"]"
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.resource_prefix}-control-alert-handler"

  policy_arns = [
    aws_iam_policy.control_alert_handler.arn,
    module.control_clickup_integration.invoke_policy_arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["control_alert_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.12"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.control_alert_handler.name
  principal     = "logs.${local.current_region}.amazonaws.com"
}

###########################
## control-clickup-integration ##
###########################
module "control_clickup_integration" {
  description     = "Configurable integration to open clickup tasks from CW alarms and Log Filter Subscriptions"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    ENVIRONMENT = var.resource_prefix
    TEAM        = "EchoStream"
    SPACE       = "EchoStream MVP"
    PROJECT     = "Sprints and backlogs"
    TASK_LIST   = "Bugs"
    ASSIGN_TO   = "mmoon@quinovas.com"
    API_KEY     = "pk_10629580_3BHCYV0Y5Z8C5IL1LPJP7PWSJP0HZB6M"
  }

  handler       = "function.handler"
  kms_key_arn   = local.lambda_env_vars_kms_key_arn
  memory_size   = 1536
  name          = "${var.resource_prefix}-control-clickup-integration"
  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["control_clickup_integration"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.12"
}