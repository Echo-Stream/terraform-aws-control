####################################
## Manage Graph Table - Read Only ##
####################################
data "aws_iam_policy_document" "graph_ddb_read" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
    ]

    resources = [
      data.aws_dynamodb_table.graph_table.arn,
    ]

    sid = "TableAccessRead"
  }

  statement {
    actions = [
      "dynamodb:Query"
    ]

    resources = [
      data.aws_dynamodb_table.graph_table.arn,
      "${data.aws_dynamodb_table.graph_table.arn}/index/*"
    ]

    sid = "TableAccessQuery"
  }
}

resource "aws_iam_policy" "graph_ddb_read" {
  description = "IAM permissions to read graph-table"
  name        = "${var.name}-graph-table-read"
  policy      = data.aws_iam_policy_document.graph_ddb_read.json
}

##########################################
##  app-cognito-pre-authentication  ##
##########################################
data "aws_iam_policy_document" "app_cognito_pre_authentication" {
  statement {
    actions = [
      "dynamodb:Query",
    ]

    resources = [
      data.aws_dynamodb_table.graph_table.arn,
      "${data.aws_dynamodb_table.graph_table.arn}/*",
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]

    sid = "CWPutMetrics"
  }
}

resource "aws_iam_policy" "app_cognito_pre_authentication" {
  description = "IAM permissions required for app-cognito-pre-authentication lambda"
  name        = "${var.name}-app-cognito-pre-authentication"
  policy      = data.aws_iam_policy_document.app_cognito_pre_authentication.json
}

module "app_cognito_pre_authentication" {
  description = "Function that gets triggered when cognito user to be authenticated"

  environment_variables = {
    CONTROL_REGION = var.control_region
    DYNAMODB_TABLE = var.graph_table_name
    ENVIRONMENT    = var.environment
    TENANT_REGIONS = var.tenant_regions
  }

  dead_letter_arn = var.dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = var.kms_key_arn
  memory_size     = 1536
  name            = "${var.name}-app-cognito-pre-authentication"

  policy_arns = [
    aws_iam_policy.app_cognito_pre_authentication.arn,
    aws_iam_policy.graph_ddb_read.arn
  ]

  runtime       = "python3.9"
  s3_bucket     = var.artifacts_bucket
  s3_object_key = var.function_s3_object_key
  source        = "QuiNovas/lambda/aws"
  tags          = var.tags
  timeout       = 30
  version       = "4.0.0"
}

resource "aws_lambda_permission" "app_cognito_pre_authentication" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.app_cognito_pre_authentication.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_api.arn
}