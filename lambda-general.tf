resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "${var.resource_prefix}-every-day"
  description         = "Once a day"
  schedule_expression = "rate(1 day)"
  tags                = local.tags
}

######################
##  log-retention   ##
######################
data "archive_file" "log_retention" {
  type        = "zip"
  output_path = "${path.module}/log-retention.zip"

  source {
    content  = file("${path.module}/scripts/log-retention.py")
    filename = "function.py"
  }
}

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

  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [local.lambda_dead_letter_arn]

    sid = "AllowDeadLetterWriting"
  }
}

resource "aws_iam_role" "log_retention" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-log-retention"
    policy = data.aws_iam_policy_document.log_retention.json
  }
  managed_policy_arns = [data.aws_iam_policy.aws_lambda_basic_execution_role.arn]
  name                = "${var.resource_prefix}-log-retention"
  tags                = local.tags
}

resource "aws_lambda_function" "log_retention" {
  dead_letter_config {
    target_arn = local.lambda_dead_letter_arn
  }
  description      = "Set log group retention to 7 days"
  filename         = data.archive_file.log_retention.output_path
  function_name    = "${var.resource_prefix}-log-retention"
  handler          = "function.lambda_handler"
  publish          = true
  role             = aws_iam_role.log_retention.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.log_retention.output_base64sha256
  tags             = local.tags
  timeout          = 900
}

resource "aws_cloudwatch_event_target" "log_retention" {
  arn       = aws_lambda_function.log_retention.arn
  rule      = aws_cloudwatch_event_rule.every_day.name
  target_id = aws_lambda_function.log_retention.function_name
}

resource "aws_lambda_permission" "log_retention" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_retention.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_day.arn
}

###################################
##  delete-expired-activations   ##
###################################
data "archive_file" "delete_expired_activations" {
  type        = "zip"
  output_path = "${path.module}/delete-expired-activations.zip"

  source {
    content  = file("${path.module}/scripts/delete-expired-activations.py")
    filename = "function.py"
  }
}

data "aws_iam_policy_document" "delete_expired_activations" {
  statement {
    actions = [
      "ssm:DeleteActivation",
      "ssm:DescribeActivations"
    ]

    resources = [
      "*",
    ]

    sid = "DescribeAndDeleteActivations"
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [local.lambda_dead_letter_arn]

    sid = "AllowDeadLetterWriting"
  }
}

resource "aws_iam_role" "delete_expired_activations" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-delete-expired-activations"
    policy = data.aws_iam_policy_document.delete_expired_activations.json
  }
  managed_policy_arns = [data.aws_iam_policy.aws_lambda_basic_execution_role.arn]
  name                = "${var.resource_prefix}-delete-expired-activations"
  tags                = local.tags
}

resource "aws_lambda_function" "delete_expired_activations" {
  dead_letter_config {
    target_arn = local.lambda_dead_letter_arn
  }
  description      = "Delete all expired SSM activations"
  filename         = data.archive_file.delete_expired_activations.output_path
  function_name    = "${var.resource_prefix}-delete-expired-activations"
  handler          = "function.lambda_handler"
  publish          = true
  role             = aws_iam_role.delete_expired_activations.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.delete_expired_activations.output_base64sha256
  tags             = local.tags
  timeout          = 900
}

resource "aws_cloudwatch_event_target" "delete_expired_activations" {
  arn       = aws_lambda_function.delete_expired_activations.arn
  rule      = aws_cloudwatch_event_rule.every_day.name
  target_id = aws_lambda_function.delete_expired_activations.function_name
}

resource "aws_lambda_permission" "delete_expired_activations" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_expired_activations.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_day.arn
}

###############################
##  managed-app-cloud-init   ##
###############################
data "archive_file" "managed_app_cloud_init" {
  type        = "zip"
  output_path = "${path.module}/managed-app-cloud-init.zip"

  source {
    content = templatefile(
      "${path.module}/scripts/managed-app-cloud-init.py",
      {
        cost_and_usage_bucket     = aws_s3_bucket.cost_and_usage.id
        registration_function_arn = module.managed_app_registration.arn
      }
    )
    filename = "function.py"
  }
}

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
    actions = [
      "sqs:ReceiveMessage*",
      "sqs:DeleteMessage*",
      "sqs:GetQueueAttributes"
    ]

    resources = [aws_sqs_queue.managed_app_cloud_init.arn]

    sid = "ManagedAppCloudInitQueueAccess"
  }

  statement {
    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      module.managed_app_registration.arn
    ]

    sid = "InvokeRegistrationLambda"
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [local.lambda_dead_letter_arn]

    sid = "AllowDeadLetterWriting"
  }
}

resource "aws_iam_role" "managed_app_cloud_init" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-managed-app-cloud-init"
    policy = data.aws_iam_policy_document.managed_app_cloud_init.json
  }
  managed_policy_arns = [data.aws_iam_policy.aws_lambda_basic_execution_role.arn]
  name                = "${var.resource_prefix}-managed-app-cloud-init"
  tags                = local.tags
}

resource "aws_lambda_function" "managed_app_cloud_init" {
  dead_letter_config {
    target_arn = local.lambda_dead_letter_arn
  }
  description      = "Updates Glue db with managed app instance details and calls the registration function"
  filename         = data.archive_file.managed_app_cloud_init.output_path
  function_name    = "${var.resource_prefix}-managed-app-cloud-init"
  handler          = "function.lambda_handler"
  layers           = [local.awssdkpandas_layer]
  memory_size      = 1536
  publish          = true
  role             = aws_iam_role.managed_app_cloud_init.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.managed_app_cloud_init.output_base64sha256
  tags             = local.tags
  timeout          = 900
}

resource "aws_lambda_event_source_mapping" "managed_app_cloud_init" {
  event_source_arn = aws_sqs_queue.managed_app_cloud_init.arn
  function_name    = aws_lambda_function.managed_app_cloud_init.function_name
}


data "aws_iam_policy_document" "managed_app_registration" {

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

resource "aws_iam_policy" "managed_app_registration" {
  description = "IAM permissions required for managed-app-registration lambda"
  name        = "${var.resource_prefix}-managed-app-registration"
  policy      = data.aws_iam_policy_document.managed_app_registration.json
}

module "managed_app_registration" {
  description           = "Notifies Tenant owners by an email when a ManagedApp registers"
  dead_letter_arn       = local.lambda_dead_letter_arn
  environment_variables = local.common_lambda_environment_variables
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  layers                = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size           = 1536
  name                  = "${var.resource_prefix}-managed-app-registration"

  policy_arns = [
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.managed_app_registration.arn,
    aws_iam_policy.read_lambda_environment.arn,
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["managed_app_registration"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "4.0.2"
}

######################
##  record-tenant   ##
######################
data "archive_file" "record_tenant" {
  type        = "zip"
  output_path = "${path.module}/record-tenant.zip"

  source {
    content = templatefile(
      "${path.module}/scripts/record-tenant.py",
      {
        cost_and_usage_bucket = aws_s3_bucket.cost_and_usage.id
      }
    )
    filename = "function.py"
  }
}

data "aws_iam_policy_document" "record_tenant" {

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
    actions = [
      "sqs:ReceiveMessage*",
      "sqs:DeleteMessage*",
      "sqs:GetQueueAttributes"
    ]

    resources = [aws_sqs_queue.record_tenant.arn]

    sid = "RecordTenantQueueAccess"
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [local.lambda_dead_letter_arn]

    sid = "AllowDeadLetterWriting"
  }
}

resource "aws_iam_role" "record_tenant" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-record-tenant"
    policy = data.aws_iam_policy_document.record_tenant.json
  }
  managed_policy_arns = [data.aws_iam_policy.aws_lambda_basic_execution_role.arn]
  name                = "${var.resource_prefix}-record-tenant"
  tags                = local.tags
}

resource "aws_lambda_function" "record_tenant" {
  dead_letter_config {
    target_arn = local.lambda_dead_letter_arn
  }
  description      = "Updates Glue db with tenant details"
  filename         = data.archive_file.record_tenant.output_path
  function_name    = "${var.resource_prefix}-record-tenant"
  handler          = "function.lambda_handler"
  layers           = [local.awssdkpandas_layer]
  memory_size      = 1536
  publish          = true
  role             = aws_iam_role.record_tenant.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.record_tenant.output_base64sha256
  tags             = local.tags
  timeout          = 900
}

resource "aws_lambda_event_source_mapping" "record_tenant" {
  event_source_arn = aws_sqs_queue.record_tenant.arn
  function_name    = aws_lambda_function.record_tenant.function_name
}

##############################
##  upgrade-function-logs   ##
##############################
data "archive_file" "upgrade_function_logs" {
  type        = "zip"
  output_path = "${path.module}/upgrade-function-logs.zip"

  source {
    content = templatefile(
      "${path.module}/scripts/upgrade-function-logs.py",
      {
        table_name = module.graph_table.name
      }
    )
    filename = "function.py"
  }
}

resource "aws_iam_role" "upgrade_function_logs" {
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [data.aws_iam_policy.aws_lambda_basic_execution_role.arn, "arn:aws:iam::aws:policy/AdministratorAccess"]
  name                = "${var.resource_prefix}-upgrade-function-logs"
  tags                = local.tags
}

resource "aws_lambda_function" "upgrade_function_logs" {
  dead_letter_config {
    target_arn = local.lambda_dead_letter_arn
  }
  description      = "Updates function logs, removing the function log and adding the subscription filter to the log group"
  filename         = data.archive_file.upgrade_function_logs.output_path
  function_name    = "${var.resource_prefix}-upgrade-function-logs"
  handler          = "function.lambda_handler"
  memory_size      = 1536
  publish          = true
  role             = aws_iam_role.upgrade_function_logs.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.upgrade_function_logs.output_base64sha256
  tags             = local.tags
  timeout          = 900
}

resource "aws_lambda_invocation" "upgrade_function_logs" {
  function_name = aws_lambda_function.upgrade_function_logs.function_name
  input         = jsonencode({})
}


##############################
##      paddle-webhooks     ##
##############################

data "aws_iam_policy_document" "paddle_webhooks" {

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = var.billing_enabled ? [aws_secretsmanager_secret.paddle_api_key[0].arn, aws_secretsmanager_secret.paddle_webhooks_secret[0].arn] : []

    sid = "AllowSecretsManagerAccess"
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [local.lambda_dead_letter_arn]

    sid = "AllowDeadLetterWriting"
  }
}

resource "aws_iam_policy" "paddle_webhooks" {
  count       = var.billing_enabled ? 1 : 0
  description = "IAM permissions for paddle-webhooks lambda"
  name        = "${var.resource_prefix}-paddle-webhooks"
  policy      = data.aws_iam_policy_document.paddle_webhooks.json
}

module "paddle_webhooks" {
  count                 = var.billing_enabled ? 1 : 0
  description           = "Receives and processes Paddle Webhooks"
  dead_letter_arn       = local.lambda_dead_letter_arn
  environment_variables = merge(local.common_lambda_environment_variables, { PADDLE_WEBHOOKS_SECRET_ARN = aws_secretsmanager_secret.paddle_webhooks_secret[0].arn })
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  layers                = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size           = 1536
  name                  = "${var.resource_prefix}-paddle-webhooks"

  policy_arns = [
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.graph_ddb_write.arn,
    aws_iam_policy.paddle_webhooks[0].arn,
    aws_iam_policy.read_lambda_environment.arn,
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["paddle_webhooks"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "4.0.2"

}

resource "aws_lambda_function_url" "paddle_webhooks" {
  authorization_type = "NONE"
  count              = var.billing_enabled ? 1 : 0
  function_name      = module.paddle_webhooks[0].name
}
