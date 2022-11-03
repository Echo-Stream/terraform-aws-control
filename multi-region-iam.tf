resource "aws_iam_role" "app_cognito_pre_authentication_function" {
  name               = "${var.resource_prefix}-app-cognito-pre-authentication"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
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
    resources = [
      aws_kms_key.lambda_environment_variables.arn,
      module.lambda_underpin_us_east_2.kms_key_arn,
      module.lambda_underpin_us_west_1.kms_key_arn,
      module.lambda_underpin_us_west_2.kms_key_arn,
    ]
    sid = "AllowEcryptDecryptEnvVars"
  }
  statement {
    actions = [
      "sns:Publish",
      "sqs:SendMessage",
    ]
    resources = [
      aws_sns_topic.lambda_dead_letter.arn,
      module.lambda_underpin_us_east_2.dead_letter_arn,
      module.lambda_underpin_us_west_1.dead_letter_arn,
      module.lambda_underpin_us_west_2.dead_letter_arn
    ]
    sid = "AllowDeadLetterWriting"
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

resource "aws_iam_role_policy" "app_cognito_pre_authentication_function_basic" {
  name   = "basic-access"
  policy = data.aws_iam_policy_document.app_cognito_pre_authentication_function_basic.json
  role   = aws_iam_role.app_cognito_pre_authentication_function.id
}

resource "aws_iam_role_policy_attachment" "graph_ddb_read" {
  policy_arn = aws_iam_policy.graph_ddb_read.arn
  role       = aws_iam_role.app_cognito_pre_authentication_function.name
}