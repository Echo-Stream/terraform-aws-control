#####################
## Remote APP IAM ##
####################
data "aws_iam_policy_document" "remote_app_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity"
    ]
    principals {
      identifiers = [
        module.appsync_datasource.role_arn
      ]
      type = "AWS"
    }
  }
}

# Admin Access. This is constrained when the role is assumed inside of echo-tools
resource "aws_iam_role" "remote_app" {
  managed_policy_arns = [data.aws_iam_policy.administrator_access.arn]
  name                = "${var.resource_prefix}-remote-app"
  assume_role_policy  = data.aws_iam_policy_document.remote_app_assume_role.json
  tags                = local.tags
}

############################
## Internal Node IAM ##
############################
resource "aws_iam_role" "internal_node" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {
    name   = "${var.resource_prefix}-internal-node"
    policy = data.aws_iam_policy_document.internal_node.json
  }
  managed_policy_arns = [
    data.aws_iam_policy.aws_lambda_basic_execution_role.arn,
    aws_iam_policy.update_code_sts_assume.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.tenant_table_read_write.arn,
    aws_iam_policy.tenant_firehose_write.arn,
  ]
  name = "${var.resource_prefix}-internal-node"
  tags = local.tags
}

data "aws_iam_policy_document" "internal_node" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage*",
      "sqs:DeleteMessage*",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:edge*.fifo",
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:dead-letter*.fifo"
    ]

    sid = "EdgeQueuesAccess"
  }
}

############################
## Auditor IAM ##
############################
resource "aws_iam_role" "auditor" {
  managed_policy_arns = [
    data.aws_iam_policy.aws_lambda_basic_execution_role.arn,
    aws_iam_policy.update_code_sts_assume.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.tenant_firehose_write.arn
  ]
  name               = "${var.resource_prefix}-auditor"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

###################
## Validator IAM ##
###################
resource "aws_iam_role" "validator" {
  managed_policy_arns = [
    data.aws_iam_policy.aws_lambda_basic_execution_role.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.update_code_sts_assume.arn,
  ]
  name               = "${var.resource_prefix}-validator"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

#####################
## Update-Code IAM ##
#####################
data "aws_iam_policy_document" "conditional_lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity"
    ]
    principals {
      identifiers = [
        aws_iam_role.auditor.arn,
        aws_iam_role.internal_node.arn,
        aws_iam_role.validator.arn,
      ]
      type = "AWS"
    }

    condition {
      test = "StringEquals"
      values = [
        "518849732",
        "296027047",
        "181404377"
      ] # these values are encoded inside lambda code
      variable = "sts:SourceIdentity"
    }
  }
}

resource "aws_iam_role" "update_code" {
  assume_role_policy = data.aws_iam_policy_document.conditional_lambda_assume_role.json
  inline_policy {
    name   = "update-code"
    policy = data.aws_iam_policy_document.update_code.json
  }
  managed_policy_arns = [
    data.aws_iam_policy.aws_lambda_basic_execution_role.arn,
    aws_iam_policy.artifacts_bucket_read.arn,
    aws_iam_policy.graph_ddb_read.arn,
  ]
  name = "${var.resource_prefix}-update-code"
  tags = local.tags
}

data "aws_iam_policy_document" "update_code" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:GetFunction",
      "lambda:ListFunctions",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = ["*"]

    sid = "UpdateLambda"
  }
}

data "aws_iam_policy_document" "update_code_sts_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [aws_iam_role.update_code.arn]

    sid = "AssumeRole"
  }
  statement {
    effect = "Allow"

    actions = [
      "sts:SetSourceIdentity",
    ]

    resources = [aws_iam_role.update_code.arn]

    sid = "SetSourceIdentity"

    condition {
      test = "StringLike"
      values = [
        "518849732",
        "296027047",
        "181404377"
      ]
      variable = "sts:SourceIdentity"
    }
  }
}

resource "aws_iam_policy" "update_code_sts_assume" {
  description = "IAM permissions required for tenant functions to assume update code role"

  name   = "${var.resource_prefix}-update-code-sts-assume"
  policy = data.aws_iam_policy_document.update_code_sts_assume.json
}

