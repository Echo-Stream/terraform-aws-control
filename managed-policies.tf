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
      "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}-graph",
    ]

    sid = "TableAccessRead"
  }

  statement {
    actions = [
      "dynamodb:Query",
      "dynamodb:Scan",
    ]

    resources = [
      "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}-graph",
      "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}-graph/index/*"
    ]

    sid = "TableAccessQuery"
  }
}

resource "aws_iam_policy" "graph_ddb_read" {
  description = "IAM permissions to read graph-table"
  name        = "${var.resource_prefix}-graph-table-read"
  policy      = data.aws_iam_policy_document.graph_ddb_read.json
}

######################################
##### Manage Graph Table - Write #####
######################################
data "aws_iam_policy_document" "graph_ddb_write" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "WriteAccesstoTable"
  }
}

resource "aws_iam_policy" "graph_ddb_write" {
  description = "IAM permissions to write graph-table"

  name   = "${var.resource_prefix}-graph-table-write"
  policy = data.aws_iam_policy_document.graph_ddb_write.json
}

#################################
##### Artifacts Bucket Read #####
#################################
data "aws_iam_policy_document" "artifacts_bucket_read" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-*",
    ]

    sid = "ListArtifactsBucket"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-*/${var.echostream_version}/*",
    ]

    sid = "GetArtifacts"
  }
}

resource "aws_iam_policy" "artifacts_bucket_read" {
  description = "IAM permissions to read Artifact Buckets"

  name   = "${var.resource_prefix}-artifacts-bucket-read"
  policy = data.aws_iam_policy_document.artifacts_bucket_read.json
}

#################################
## Tenant Table - Read & Write ##
#################################
data "aws_iam_policy_document" "tenant_table_read_write" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:*Item",
      "dynamodb:DescribeTable",
      "dynamodb:Query",
      "dynamodb:PartiQL*",
      "dynamodb:Scan",
    ]

    resources = [
      "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/tenant-*"
    ]

    sid = "TenantTableAccessReadWrite"
  }

  statement {
    actions = [
      "dynamodb:Query",
      "dynamodb:PartiQLSelect",
      "dynamodb:Scan",
    ]

    resources = [
      "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/tenant-*/index/*"
    ]

    sid = "TenantTableIndexAccessRead"
  }
}

resource "aws_iam_policy" "tenant_table_read_write" {
  description = "IAM permissions to read and write Tenant tables"

  name   = "${var.resource_prefix}-tenant-table-read-write"
  policy = data.aws_iam_policy_document.tenant_table_read_write.json
}

#############################
## Tenant Firehose - Write ##
#############################
data "aws_iam_policy_document" "tenant_firehose_write" {
  statement {
    effect = "Allow"

    actions = [
      "firehose:PutRecord*"
    ]

    resources = [
      "arn:aws:firehose:*:${data.aws_caller_identity.current.account_id}:deliverystream/tenant-*"
    ]

    sid = "WriteAuditRecords"
  }

}

resource "aws_iam_policy" "tenant_firehose_write" {
  description = "IAM permissions required to write to Tenant firehose"

  name   = "${var.resource_prefix}-tenant-firehose-write"
  policy = data.aws_iam_policy_document.tenant_firehose_write.json
}

################
## ECR - Read ##
################
data "aws_iam_policy_document" "ecr_read" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr-public:DescribeImages",
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken"
    ]

    resources = [
      "*"
    ]

    sid = "ECRAccess"
  }
}

resource "aws_iam_policy" "ecr_read" {
  description = "IAM permissions to get ECR images"

  name   = "${var.resource_prefix}-ecr-read"
  policy = data.aws_iam_policy_document.ecr_read.json
}
