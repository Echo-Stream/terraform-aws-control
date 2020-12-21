resource "aws_sns_topic" "tenant_usage_executions" {
  name         = "${var.environment_prefix}-tenant-usage-executions"
  display_name = "${var.environment_prefix} Tenant Usage Executions"
  tags         = local.tags
}

## IAM Roles
## Error Handler ##
resource "aws_iam_role" "error_handler_role" {
  name               = "${var.environment_prefix}-error-handler"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "error_handler_role_basic" {
  role       = aws_iam_role.error_handler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "error_handler_role" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = ["*"]

  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "error_handler_role" {
  description = "IAM permissions required for Node Error Publisher functions"
  path        = "/${var.environment_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.error_handler_role.json
}

resource "aws_iam_role_policy_attachment" "error_handler_role" {
  role       = aws_iam_role.error_handler_role.name
  policy_arn = aws_iam_policy.error_handler_role.arn
}

## Alert Handler ##
resource "aws_iam_role" "alert_handler_role" {
  name               = "${var.environment_prefix}-alert-handler"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "alert_handler_role_basic" {
  role       = aws_iam_role.alert_handler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "alert_handler_role" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = ["*"]

  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:GetFunction"
    ]

    resources = ["*"]

  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "alert_handler_role" {
  description = "IAM permissions required for Node alert Publisher functions"
  path        = "/${var.environment_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.alert_handler_role.json
}

resource "aws_iam_role_policy_attachment" "alert_handler_role" {
  role       = aws_iam_role.alert_handler_role.name
  policy_arn = aws_iam_policy.alert_handler_role.arn
}

## Alarm Handler ##
resource "aws_iam_role" "alarm_handler_role" {
  name               = "${var.environment_prefix}-alarm-handler"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "alarm_handler_role_basic" {
  role       = aws_iam_role.alarm_handler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "alarm_handler_role" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = ["*"]

  }
}

resource "aws_iam_policy" "alarm_handler_role" {
  description = "IAM permissions required for Node alarm Publisher functions"
  path        = "/${var.environment_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.alarm_handler_role.json
}

resource "aws_iam_role_policy_attachment" "alarm_handler_role" {
  role       = aws_iam_role.alarm_handler_role.name
  policy_arn = aws_iam_policy.alarm_handler_role.arn
}