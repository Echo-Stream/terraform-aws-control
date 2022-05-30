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

resource "aws_iam_role" "remote_app" {
  name               = "${var.resource_prefix}-remote-app"
  assume_role_policy = data.aws_iam_policy_document.remote_app_assume_role.json
  tags               = local.tags
}

# Admin Access. This is constrained when the role is assumed inside of echo-tools
resource "aws_iam_role_policy_attachment" "remote_app_basic" {
  role       = aws_iam_role.remote_app.name
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

############################
## Internal Node IAM ##
############################
resource "aws_iam_role" "internal_node" {
  name               = "${var.resource_prefix}-internal-node"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "internal_node_basic" {
  role       = aws_iam_role.internal_node.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
      "arn:aws:sqs:*:${local.current_account_id}:edge*.fifo",
      "arn:aws:sqs:*:${local.current_account_id}:dead-letter*.fifo"
    ]

    sid = "EdgeQueuesAccess"
  }
}

resource "aws_iam_role_policy" "internal_node" {
  name    = "${var.resource_prefix}-internal-node"
  policy  = data.aws_iam_policy_document.internal_node.json
  role    = aws_iam_role.internal_node.name
}

resource "aws_iam_role_policy_attachment" "internal_node_sts_assume" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.update_code_sts_assume.arn
}

resource "aws_iam_role_policy_attachment" "internal_node_graph_ddb_read" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.graph_ddb_read.arn
}

resource "aws_iam_role_policy_attachment" "internal_node_tenant_table_read_write" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.tenant_table_read_write.arn
}

resource "aws_iam_role_policy_attachment" "internal_node_tenant_firehose_write" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.tenant_firehose_write.arn
}

############################
## Auditor IAM ##
############################
resource "aws_iam_role" "auditor" {
  name               = "${var.resource_prefix}-auditor"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "auditor_basic" {
  role       = aws_iam_role.auditor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "auditor_sts_assume" {
  role       = aws_iam_role.auditor.name
  policy_arn = aws_iam_policy.update_code_sts_assume.arn
}

resource "aws_iam_role_policy_attachment" "auditor_graph_ddb_read" {
  role       = aws_iam_role.auditor.name
  policy_arn = aws_iam_policy.graph_ddb_read.arn
}

resource "aws_iam_role_policy_attachment" "auditor_tenant_firehose_write" {
  role       = aws_iam_role.auditor.name
  policy_arn = aws_iam_policy.tenant_firehose_write.arn
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
  policy_arn = aws_iam_policy.graph_ddb_read.arn
}

resource "aws_iam_role_policy_attachment" "validator_sts_assume" {
  role       = aws_iam_role.validator.name
  policy_arn = aws_iam_policy.update_code_sts_assume.arn
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
  name               = "${var.resource_prefix}-update-code"
  assume_role_policy = data.aws_iam_policy_document.conditional_lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "update_code_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.update_code.name
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

resource "aws_iam_role_policy" "update_code" {
  name    = "update-code"
  policy  = data.aws_iam_policy_document.update_code.json
  role    = aws_iam_role.update_code.name
}

resource "aws_iam_role_policy_attachment" "update_code_artifacts_read" {
  role       = aws_iam_role.update_code.name
  policy_arn = aws_iam_policy.artifacts_bucket_read.arn
}


resource "aws_iam_role_policy_attachment" "update_code_graph_ddb_access" {
  role       = aws_iam_role.update_code.name
  policy_arn = aws_iam_policy.graph_ddb_read.arn
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

