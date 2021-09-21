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


data "aws_iam_policy_document" "internal_node_validator_common_access" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query"
    ]

    resources = [module.graph_table.arn]

    sid = "GraphTableAccess"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${var.echostream_version}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${var.echostream_version}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${var.echostream_version}/*",

    ]

    sid = "GetArtifacts"
  }
}

resource "aws_iam_policy" "internal_node" {
  description = "IAM permissions required for tenant functions"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.internal_node.json
}

resource "aws_iam_role_policy_attachment" "internal_node" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.internal_node.arn
}

resource "aws_iam_policy" "internal_node_sts_assume" {
  description = "IAM permissions required for internal nodes to assume update code role"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.internal_node_sts_assume.json
}

resource "aws_iam_role_policy_attachment" "internal_node_sts_assume" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.internal_node_sts_assume.arn
}

resource "aws_iam_policy" "internal_node_validator_common_access" {
  description = "IAM permissions required for tenant functions to touch DB"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.internal_node_validator_common_access.json
}

resource "aws_iam_role_policy_attachment" "internal_node_validator_common_access" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.internal_node_validator_common_access.arn
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
  policy_arn = aws_iam_policy.internal_node_validator_common_access.arn
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