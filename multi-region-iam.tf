resource "aws_iam_role" "app_cognito_pre_authentication_function" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "basic-access"
    policy = data.aws_iam_policy_document.app_cognito_pre_authentication_function_basic.json
  }
  managed_policy_arns = [aws_iam_policy.graph_ddb_read.arn]
  name                = "${var.resource_prefix}-app-cognito-pre-authentication"
  tags                = var.tags
}

data "aws_iam_policy_document" "app_cognito_pre_authentication_function_basic" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.resource_prefix}-app-cognito-pre-authentication:*",
    ]
    sid = "AllowLogWriting"
  }
  statement {
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
    ]
    resources = local.regional_kms_key_arns
    sid       = "AllowEcryptDecryptEnvVars"
  }
  statement {
    actions = [
      "sns:Publish",
      "sqs:SendMessage",
    ]
    resources = local.regional_dead_letter_arns
    sid       = "AllowDeadLetterWriting"
  }
  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
    ]
    resources = [
      "*",
    ]
    sid = "AllowWritingXRay"
  }
}
