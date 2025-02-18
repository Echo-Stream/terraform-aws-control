resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "${var.resource_prefix}-every-day"
  description         = "Once a day"
  schedule_expression = "rate(1 day)"
  tags                = local.tags
}

########################
## audit-consolidator ##
########################

data "archive_file" "audit_consolidator" {
  type        = "zip"
  output_path = "${path.module}/audit-consolidator.zip"

  source {
    content = templatefile(
      "${path.module}/scripts/audit-consolidator.py",
      {
        audit_consolidator_topic_arn = aws_sns_topic.audit_consolidator.arn
        tenant_regions               = jsonencode(var.tenant_regions)
      }
    )
    filename = "function.py"
  }
}

resource "aws_cloudwatch_event_rule" "audit_consolidator" {
  name                = "${var.resource_prefix}-audit-consolidator"
  description         = "Consolidate audit logs from all tenants"
  schedule_expression = "cron(0 3 * * ? *)" # 3am UTC
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "audit_consolidator" {
  arn        = aws_lambda_function.audit_consolidator.arn
  depends_on = [aws_lambda_permission.cloudwatch_audit_consolidator]
  rule       = aws_cloudwatch_event_rule.audit_consolidator.name
  target_id  = aws_lambda_function.audit_consolidator.function_name
}

data "aws_iam_policy_document" "audit_consolidator" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::tenant-*",
    ]

    sid = "ListBuckets"
  }

  statement {
    actions = [
      "s3:ListAllMyBuckets",
    ]

    resources = ["*"]

    sid = "ListAllBuckets"
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::tenant-*/audit-records/records/*",
    ]

    sid = "ReadAndDeleteAuditRecords"
  }

  statement {
    actions = [
      "s3:PutObject*",
    ]

    resources = [
      "arn:aws:s3:::tenant-*/audit-records/archive/*",
    ]

    sid = "WriteArchiveAuditRecords"
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
    ]

    resources = ["*"]

    sid = "KMSAccess"
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [
      local.lambda_dead_letter_arn,
      aws_sns_topic.audit_consolidator.arn,
    ]

    sid = "AllowSNSWriting"
  }
}

resource "aws_iam_role" "audit_consolidator" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-audit-consolidator"
    policy = data.aws_iam_policy_document.audit_consolidator.json
  }
  managed_policy_arns = [
    data.aws_iam_policy.aws_lambda_basic_execution_role.arn,
  ]
  name = "${var.resource_prefix}-audit-consolidator"
  tags = local.tags
}

resource "aws_lambda_function" "audit_consolidator" {
  dead_letter_config {
    target_arn = local.lambda_dead_letter_arn
  }
  description      = "Consolidate audit logs from all tenants"
  filename         = data.archive_file.audit_consolidator.output_path
  function_name    = "${var.resource_prefix}-audit-consolidator"
  handler          = "function.lambda_handler"
  layers           = [local.awssdkpandas_layer]
  memory_size      = 1536
  publish          = true
  role             = aws_iam_role.audit_consolidator.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.audit_consolidator.output_base64sha256
  tags             = local.tags
  timeout          = 900
}

resource "aws_lambda_permission" "cloudwatch_audit_consolidator" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.audit_consolidator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.audit_consolidator.arn
  statement_id  = "AllowExecutionFromCloudWatch"
}

resource "aws_lambda_permission" "sns_audit_consolidator" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.audit_consolidator.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.audit_consolidator.arn
  statement_id  = "AllowExecutionFromSNS"
}

resource "aws_sns_topic" "audit_consolidator" {
  name = "${var.resource_prefix}-audit-consolidator"
  tags = local.tags
}

resource "aws_sns_topic_subscription" "audit_consolidator" {
  endpoint   = aws_lambda_function.audit_consolidator.arn
  depends_on = [aws_lambda_permission.sns_audit_consolidator]
  topic_arn  = aws_sns_topic.audit_consolidator.arn
  protocol   = "lambda"
}

#########################
##  bill-subscriptions ##
#########################

data "archive_file" "bill_subscriptions" {
  type        = "zip"
  output_path = "${path.module}/bill-subscriptions.zip"

  source {
    content = templatefile(
      "${path.module}/scripts/bill-subscriptions.py",
      {
        athena_workgroup            = aws_athena_workgroup.echostream_athena.name
        billing_database            = aws_glue_catalog_database.billing.name
        bill_subscription_topic_arn = var.billing_enabled ? aws_sns_topic.bill_subscriptions[0].arn : ""
        cost_and_usage_bucket       = aws_s3_bucket.cost_and_usage.id
        paddle_api_key_secret_arn   = local.paddle_api_key_secret_arn
        paddle_base_url             = local.paddle_base_url
        paddle_usage_price_amount   = var.paddle_usage_price_amount
        usage_product_id            = can(var.paddle_product_ids.usage) ? var.paddle_product_ids.usage : "unknown"
        usage_multiple              = local.usage_multiple
      }
    )
    filename = "function.py"
  }
}

resource "aws_cloudwatch_event_rule" "bill_subscriptions" {
  count               = var.billing_enabled ? 1 : 0
  description         = "Bill tenant subscriptions once per month"
  name                = "${var.resource_prefix}-bill-subscriptions"
  schedule_expression = "cron(0 6 3 * ? *)" # 6am UTC on the 3rd of every month
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "bill_subscriptions" {
  arn        = aws_lambda_function.bill_subscriptions[0].arn
  count      = var.billing_enabled ? 1 : 0
  depends_on = [aws_lambda_permission.cloudwatch_bill_subscriptions[0]]
  rule       = aws_cloudwatch_event_rule.bill_subscriptions[0].name
  target_id  = aws_lambda_function.bill_subscriptions[0].function_name
}

data "aws_iam_policy_document" "bill_subscriptions" {
  statement {
    actions = [
      "s3:GetObject*",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.cost_and_usage.arn,
      "${aws_s3_bucket.cost_and_usage.arn}/*",
    ]

    sid = "AccessCostAndUsageBucket"
  }

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

    resources = [
      local.lambda_dead_letter_arn,
      var.billing_enabled ? aws_sns_topic.bill_subscriptions[0].arn : "",
    ]

    sid = "AllowSNSWriting"
  }
}

resource "aws_iam_role" "bill_subscriptions" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  count              = var.billing_enabled ? 1 : 0
  inline_policy {
    name   = "${var.resource_prefix}-bill-subscriptions"
    policy = data.aws_iam_policy_document.bill_subscriptions.json
  }
  managed_policy_arns = [
    data.aws_iam_policy.athena_full_access.arn,
    aws_iam_policy.athena_query_results_access.arn,
    data.aws_iam_policy.aws_lambda_basic_execution_role.arn,
  ]
  name = "${var.resource_prefix}-bill-subscriptions"
  tags = local.tags
}

resource "aws_lambda_function" "bill_subscriptions" {
  count = var.billing_enabled ? 1 : 0
  dead_letter_config {
    target_arn = local.lambda_dead_letter_arn
  }
  description      = "Bill all tenant subscriptions for the previous month"
  filename         = data.archive_file.bill_subscriptions.output_path
  function_name    = "${var.resource_prefix}-bill-subscriptions"
  handler          = "function.lambda_handler"
  layers           = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size      = 1536
  publish          = true
  role             = aws_iam_role.bill_subscriptions[0].arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.bill_subscriptions.output_base64sha256
  tags             = local.tags
  timeout          = 900
}

resource "aws_lambda_permission" "cloudwatch_bill_subscriptions" {
  action        = "lambda:InvokeFunction"
  count         = var.billing_enabled ? 1 : 0
  function_name = aws_lambda_function.bill_subscriptions[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bill_subscriptions[0].arn
  statement_id  = "AllowExecutionFromCloudWatch"
}

resource "aws_lambda_permission" "sns_bill_subscriptions" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  count         = var.billing_enabled ? 1 : 0
  function_name = aws_lambda_function.bill_subscriptions[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.bill_subscriptions[0].arn
}

resource "aws_sns_topic" "bill_subscriptions" {
  count = var.billing_enabled ? 1 : 0
  name  = "${var.resource_prefix}-bill-subscriptions"
  tags  = local.tags
}

resource "aws_sns_topic_subscription" "bill_subscriptions" {
  count      = var.billing_enabled ? 1 : 0
  depends_on = [aws_lambda_permission.sns_bill_subscriptions[0]]
  endpoint   = aws_lambda_function.bill_subscriptions[0].arn
  topic_arn  = aws_sns_topic.bill_subscriptions[0].arn
  protocol   = "lambda"
}


#####################
##  compute-usage  ##
#####################

data "archive_file" "compute_usage" {
  type        = "zip"
  output_path = "${path.module}/compute-usage.zip"

  source {
    content = templatefile(
      "${path.module}/scripts/compute-usage.py",
      {
        athena_workgroup        = aws_athena_workgroup.echostream_athena.name
        billing_database        = aws_glue_catalog_database.billing.name
        cost_and_usage_bucket   = aws_s3_bucket.cost_and_usage.id
        compute_usage_topic_arn = aws_sns_topic.compute_usage.arn
        system_alarm_count      = (length(local.non_control_regions) * 2) + length(local.lambda_names) + length(local.sqs_names) + 2
      }
    )
    filename = "function.py"
  }
}

resource "aws_cloudwatch_event_rule" "compute_usage" {
  name                = "${var.resource_prefix}-compute-usage"
  description         = "Compute tenant usage once per hour"
  schedule_expression = "rate(1 hour)"
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "compute_usage" {
  arn        = aws_lambda_function.compute_usage.arn
  depends_on = [aws_lambda_permission.cloudwatch_compute_usage]
  rule       = aws_cloudwatch_event_rule.compute_usage.name
  target_id  = aws_lambda_function.compute_usage.function_name
}

data "aws_iam_policy_document" "compute_usage" {
  statement {
    actions = [
      "s3:GetObject*",
      "s3:ListBucket",
      "s3:PutObject*",
    ]

    resources = [
      aws_s3_bucket.cost_and_usage.arn,
      "${aws_s3_bucket.cost_and_usage.arn}/*",
    ]

    sid = "AccessCostAndUsageBucket"
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [
      local.lambda_dead_letter_arn,
      aws_sns_topic.compute_usage.arn,
    ]

    sid = "AllowSNSWriting"
  }
}

resource "aws_iam_role" "compute_usage" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-compute-usage"
    policy = data.aws_iam_policy_document.compute_usage.json
  }
  managed_policy_arns = [
    data.aws_iam_policy.athena_full_access.arn,
    aws_iam_policy.athena_query_results_access.arn,
    data.aws_iam_policy.aws_lambda_basic_execution_role.arn,
  ]
  name = "${var.resource_prefix}-compute-usage"
  tags = local.tags
}

resource "aws_lambda_function" "compute_usage" {
  dead_letter_config {
    target_arn = local.lambda_dead_letter_arn
  }
  description      = "Compute usage for all tenants and store in S3 bucket"
  filename         = data.archive_file.compute_usage.output_path
  function_name    = "${var.resource_prefix}-compute-usage"
  handler          = "function.lambda_handler"
  layers           = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size      = 1536
  publish          = true
  role             = aws_iam_role.compute_usage.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.compute_usage.output_base64sha256
  tags             = local.tags
  timeout          = 900
}

resource "aws_lambda_permission" "cloudwatch_compute_usage" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.compute_usage.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.compute_usage.arn
}

resource "aws_lambda_permission" "sns_compute_usage" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.compute_usage.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.compute_usage.arn
}

resource "aws_sns_topic" "compute_usage" {
  name = "${var.resource_prefix}-compute-usage"
  tags = local.tags
}

resource "aws_sns_topic_subscription" "compute_usage" {
  depends_on = [aws_lambda_permission.sns_compute_usage]
  endpoint   = aws_lambda_function.compute_usage.arn
  topic_arn  = aws_sns_topic.compute_usage.arn
  protocol   = "lambda"
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

#################################
##  managed-app-registration   ##
#################################


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

  statement {
    actions = [
      "lambda:InvokeFunction"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.resource_prefix}-paddle-webhooks",
    ]

    sid = "AllowSelfInvoke"
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
  timeout       = 900
  version       = "4.0.2"

}

resource "aws_lambda_function_url" "paddle_webhooks" {
  authorization_type = "NONE"
  count              = var.billing_enabled ? 1 : 0
  function_name      = module.paddle_webhooks[0].name
}

################################
##  record-cloudwatch-alarm   ##
################################
data "archive_file" "record_cloudwatch_alarm" {
  type        = "zip"
  output_path = "${path.module}/record-cloudwatch-alarm.zip"

  source {
    content = templatefile(
      "${path.module}/scripts/record-cloudwatch-alarm.py",
      {
        cost_and_usage_bucket = aws_s3_bucket.cost_and_usage.id
      }
    )
    filename = "function.py"
  }
}

data "aws_iam_policy_document" "record_cloudwatch_alarm" {

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

    resources = [aws_sqs_queue.record_cloudwatch_alarm.arn]

    sid = "RecordCloudwatchAlarmQueueAccess"
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [local.lambda_dead_letter_arn]

    sid = "AllowDeadLetterWriting"
  }
}

resource "aws_iam_role" "record_cloudwatch_alarm" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-record-cloudwatch-alarm"
    policy = data.aws_iam_policy_document.record_cloudwatch_alarm.json
  }
  managed_policy_arns = [data.aws_iam_policy.aws_lambda_basic_execution_role.arn]
  name                = "${var.resource_prefix}-record-cloudwatch-alarm"
  tags                = local.tags
}

resource "aws_lambda_function" "record_cloudwatch_alarm" {
  dead_letter_config {
    target_arn = local.lambda_dead_letter_arn
  }
  description      = "Updates Glue db with tenant cloudwatch alarm counts"
  filename         = data.archive_file.record_cloudwatch_alarm.output_path
  function_name    = "${var.resource_prefix}-record-cloudwatch-alarm"
  handler          = "function.lambda_handler"
  layers           = [local.awssdkpandas_layer]
  memory_size      = 1536
  publish          = true
  role             = aws_iam_role.record_cloudwatch_alarm.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.record_cloudwatch_alarm.output_base64sha256
  tags             = local.tags
  timeout          = 900
}

resource "aws_lambda_event_source_mapping" "record_cloudwatch_alarm" {
  depends_on       = [aws_iam_role.record_cloudwatch_alarm]
  event_source_arn = aws_sqs_queue.record_cloudwatch_alarm.arn
  function_name    = aws_lambda_function.record_cloudwatch_alarm.function_name
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
  depends_on       = [aws_iam_role.record_tenant]
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
