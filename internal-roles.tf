############################
## Remote APP IAM ##
############################
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

    # condition {
    #   test = "StringEquals"
    #   values = [
    #   ]
    #   variable = "sts:SourceIdentity"
    # }
  }
}

resource "aws_iam_role_policy_attachment" "remote_app_basic" {
  role       = aws_iam_role.remote_app.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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

    resources = [ #aws_kinesis_firehose_delivery_stream.process_audit_record_firehose.arn,
      "arn:aws:firehose:*:${data.aws_caller_identity.current.account_id}:deliverystream/${var.resource_prefix}-audit-records"
    ]

    sid = "WriteToFirehose"
  }

  # statement {
  #   effect = "Allow"

  #   actions = [
  #     "sns:Publish"
  #   ]

  #   resources = [
  #     "arn:aws:sns:*:${data.aws_caller_identity.current.account_id}:${var.resource_prefix}-audit-records"
  #   ]

  #   sid = "WriteToAuditRecordsSNSTopic"
  # }

  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage*",
      "sqs:DeleteMessage*",
      "sqs:GetQueueAttributes"
    ]

    resources = ["arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:edge*.fifo",
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:dead-letter*.fifo"
    ]

    sid = "EdgeQueuesAccess"
  }

  statement {
    actions = [
      "dynamodb:Query",
    ]

    resources = [
      "${module.graph_table.arn}/*",
    ]

    sid = "QueryAllIndexes"
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


data "aws_iam_policy_document" "common_db_access" {
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

resource "aws_iam_policy" "common_db_access" {
  description = "IAM permissions required for tenant functions to touch DB"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.common_db_access.json
}

resource "aws_iam_role_policy_attachment" "common_db_access" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.common_db_access.arn
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
  policy_arn = aws_iam_policy.common_db_access.arn
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

resource "aws_iam_policy" "update_code" {
  description = "IAM permissions required for internal nodes to update themselves"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.update_code.json
}

resource "aws_iam_role_policy_attachment" "update_code" {
  role       = aws_iam_role.update_code.name
  policy_arn = aws_iam_policy.update_code.arn
}

resource "aws_iam_role_policy_attachment" "update_code_db_access" {
  role       = aws_iam_role.update_code.name
  policy_arn = aws_iam_policy.common_db_access.arn
}
