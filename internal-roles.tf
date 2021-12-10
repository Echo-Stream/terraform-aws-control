#####################
## Remote APP IAM ##
####################
resource "aws_iam_role" "remote_app" {
  name               = "${var.resource_prefix}-remote-app"
  assume_role_policy = data.aws_iam_policy_document.remote_app_assume_role.json
  tags               = local.tags
}

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

resource "aws_iam_role_policy_attachment" "remote_app_basic" {
  role       = aws_iam_role.remote_app.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "remote_app_tenant_table_read_write" {
  role       = aws_iam_role.remote_app.name
  policy_arn = aws_iam_policy.tenant_table_read_write.arn
}

############################
## Internal Functions IAM ##
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
      "firehose:PutRecord*"
    ]

    resources = [
      "arn:aws:firehose:*:${local.current_account_id}:deliverystream/${var.resource_prefix}-tenant-*"
    ]

    sid = "WriteAuditRecords"
  }

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

data "aws_iam_policy_document" "internal_node_sts_assume" {
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
        "296027047"
      ]
      variable = "sts:SourceIdentity"
    }
  }
}

resource "aws_iam_policy" "internal_node" {
  description = "IAM permissions required for tenant functions"
  path        = "/lambda/control/"
  policy      = data.aws_iam_policy_document.internal_node.json
}

resource "aws_iam_role_policy_attachment" "internal_node" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.internal_node.arn
}

resource "aws_iam_policy" "internal_node_sts_assume" {
  description = "IAM permissions required for internal nodes to assume update code role"
  path        = "/lambda/control/"
  policy      = data.aws_iam_policy_document.internal_node_sts_assume.json
}

resource "aws_iam_role_policy_attachment" "internal_node_sts_assume" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.internal_node_sts_assume.arn
}

resource "aws_iam_role_policy_attachment" "internal_node_graph_ddb_read" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.graph_ddb_read.arn
}

resource "aws_iam_role_policy_attachment" "internal_node_tenant_table_read_write" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.tenant_table_read_write.arn
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
  policy_arn = aws_iam_policy.internal_node_sts_assume.arn
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
        aws_iam_role.internal_node.arn,
        aws_iam_role.validator.arn,
      ]
      type = "AWS"
    }

    condition {
      test = "StringEquals"
      values = [
        "518849732",
        "296027047"
      ]
      variable = "sts:SourceIdentity"
    }
  }
}

resource "aws_iam_role" "update_code" {
  name               = "${var.resource_prefix}-update-code"
  path               = "/lambda/tenant/"
  assume_role_policy = data.aws_iam_policy_document.conditional_lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "update_code_basic" {
  role       = aws_iam_role.update_code.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
  path        = "/lambda/tenant/"
  policy      = data.aws_iam_policy_document.update_code.json
}

resource "aws_iam_role_policy_attachment" "update_code" {
  role       = aws_iam_role.update_code.name
  policy_arn = aws_iam_policy.update_code.arn
}


resource "aws_iam_role_policy_attachment" "update_code_artifacts_read" {
  role       = aws_iam_role.update_code.name
  policy_arn = aws_iam_policy.artifacts_bucket_read.arn
}


resource "aws_iam_role_policy_attachment" "update_code_graph_ddb_access" {
  role       = aws_iam_role.update_code.name
  policy_arn = aws_iam_policy.graph_ddb_read.arn
}
