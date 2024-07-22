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
  policy_arn = data.aws_iam_policy.aws_lambda_basic_execution_role.arn
}

data "aws_iam_policy_document" "internal_node" {
  statement {
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

  statement {
    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.alarms.arn
    ]

    sid = "PublishToAlarmTopic"
  }
}

resource "aws_iam_role_policy" "internal_node" {
  name   = "${var.resource_prefix}-internal-node"
  policy = data.aws_iam_policy_document.internal_node.json
  role   = aws_iam_role.internal_node.name
}

resource "aws_iam_role_policy_attachment" "internal_node_websub_node_sts_assume" {
  role       = aws_iam_role.internal_node.name
  policy_arn = aws_iam_policy.websub_node_sts_assume.arn
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
  policy_arn = data.aws_iam_policy.aws_lambda_basic_execution_role.arn
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
  policy_arn = data.aws_iam_policy.aws_lambda_basic_execution_role.arn
}

resource "aws_iam_role_policy_attachment" "validator_db" {
  role       = aws_iam_role.validator.name
  policy_arn = aws_iam_policy.graph_ddb_read.arn
}

#####################
## WebSub Node IAM ##
#####################

data "aws_iam_policy_document" "conditional_websub_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity"
    ]
    principals {
      identifiers = [
        aws_iam_role.internal_node.arn,
      ]
      type = "AWS"
    }

    condition {
      test = "StringEquals"
      values = [
        "572982510",
        "1680410836"
      ] # these values are encoded inside lambda code
      variable = "sts:SourceIdentity"
    }
  }
}

resource "aws_iam_role" "websub_node" {
  name               = "${var.resource_prefix}-websub-node"
  assume_role_policy = data.aws_iam_policy_document.conditional_websub_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "websub_node_basic" {
  policy_arn = data.aws_iam_policy.aws_lambda_basic_execution_role.arn
  role       = aws_iam_role.websub_node.name
}

resource "aws_iam_role_policy_attachment" "websub_node_administrator" {
  policy_arn = data.aws_iam_policy.administrator_access.arn
  role       = aws_iam_role.websub_node.name
}

data "aws_iam_policy_document" "websub_node_sts_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [aws_iam_role.websub_node.arn]

    sid = "AssumeRole"
  }
  statement {
    actions = [
      "sts:SetSourceIdentity",
    ]

    resources = [aws_iam_role.websub_node.arn]

    sid = "SetSourceIdentity"

    condition {
      test = "StringLike"
      values = [
        "572982510",
        "1680410836"
      ]
      variable = "sts:SourceIdentity"
    }
  }
}

resource "aws_iam_policy" "websub_node_sts_assume" {
  description = "IAM permissions required for tenant functions to assume update code role"

  name   = "${var.resource_prefix}-web-node-sts-assume"
  policy = data.aws_iam_policy_document.websub_node_sts_assume.json
}
