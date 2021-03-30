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

############################
## Validate Functions IAM ##
############################
resource "aws_iam_role" "validate_functions_tenant_function" {
  name               = "${var.resource_prefix}-validate-functions-tenant-function"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "validate_functions_tenant_function_basic" {
  role       = aws_iam_role.validate_functions_tenant_function.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_iam_role_policy_attachment" "validate_functions_tenant_function_db_access" {
  role       = aws_iam_role.validate_functions_tenant_function.name
  policy_arn = aws_iam_policy.tenant_function_db_access.arn
}