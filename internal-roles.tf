############################
## Internal Functions IAM ##
############################
resource "aws_iam_role" "tenant_function" {
  name               = "${var.resource_prefix}-tenant-functions"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "tenant_function_basic" {
  role       = aws_iam_role.tenant_function.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "tenant_function" {
  statement {
    effect = "Allow"

    actions = [
      "firehose:PutRecord*"
    ]

    resources = [aws_kinesis_firehose_delivery_stream.process_audit_record_firehose.arn]

    sid = "WriteToFirehose"
  }

  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage*",
      "sqs:DeleteMessage*",
      "sqs:GetQueueAttributes"
    ]

    resources = ["arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:_edge_*.fifo"]

    sid = "EdgeQueuesAccess"
  }
}

data "aws_iam_policy_document" "tenant_function_db_access" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query"
    ]

    resources = [module.graph_table.arn]

    sid = "GraphTableAccess"
  }
}

resource "aws_iam_policy" "tenant_function" {
  description = "IAM permissions required for tenant functions"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.tenant_function.json
}

resource "aws_iam_role_policy_attachment" "tenant_function" {
  role       = aws_iam_role.tenant_function.name
  policy_arn = aws_iam_policy.tenant_function.arn
}

resource "aws_iam_policy" "tenant_function_db_access" {
  description = "IAM permissions required for tenant functions to touch DB"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.tenant_function_db_access.json
}

resource "aws_iam_role_policy_attachment" "tenant_function_db_access" {
  role       = aws_iam_role.tenant_function.name
  policy_arn = aws_iam_policy.tenant_function_db_access.arn
}

###################
## Validator IAM ##
###################
resource "aws_iam_role" "validator" {
  name               = "${var.resource_prefix}-validator"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "validator_basic" {
  role       = aws_iam_role.validator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "validator_db" {
  role       = aws_iam_role.validator.name
  policy_arn = aws_iam_policy.tenant_function_db_access.arn
}

#####################
## Update-Code IAM ##
#####################
data "aws_iam_policy_document" "conditional_lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "lambda.amazonaws.com",
      ]
      type = "Service"
    }

    condition {
      test = "StringEquals"
      values = [
        "1811287156321588255",
        "8418996027118263142"
      ]
      variable = "sts:SourceIdentity"
    }
  }
}

resource "aws_iam_role" "update_code" {
  name               = "${var.resource_prefix}-update-code"
  assume_role_policy = data.aws_iam_policy_document.conditional_lambda_assume_role.json
  tags               = local.tags
}

data "aws_iam_policy_document" "update_code" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:ListFunctions",
      "lambda:GetFunction",
    ]

    resources = ["*"]

    sid = "UpdateLambda"
  }
}

resource "aws_iam_policy" "update_code" {
  description = "IAM permissions required for internal nodes to update themselves"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.update_code.json
}

resource "aws_iam_role_policy_attachment" "update_code" {
  role       = aws_iam_role.update_code.name
  policy_arn = aws_iam_policy.update_code.arn
}