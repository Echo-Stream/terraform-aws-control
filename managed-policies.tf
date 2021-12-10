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
      module.graph_table.arn,
    ]

    sid = "TableAccessQuery"
  }

  statement {
    actions = [
      "dynamodb:Query"
    ]

    resources = [
      "${module.graph_table.arn}/index/*"
    ]

    sid = "TableAccessRead"
  }
}

resource "aws_iam_policy" "graph_ddb_read" {
  description = "IAM permissions to read graph-table"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-graph-table-read"
  policy      = data.aws_iam_policy_document.graph_ddb_read.json
}

######################################
##### Manage Graph Table - Write #####
######################################
data "aws_iam_policy_document" "graph_ddb_write" {
  statement {
    actions = [
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
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-graph-table-write"
  policy      = data.aws_iam_policy_document.graph_ddb_write.json
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
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2",
    ]

    sid = "ListArtifactsBucket"
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

resource "aws_iam_policy" "artifacts_bucket_read" {
  description = "IAM permissions to read Artifacts Bucket"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-artifacts-bucket-read"
  policy      = data.aws_iam_policy_document.artifacts_bucket_read.json
}

#################################
## Tenant Table - Read & Write ##
#################################
data "aws_iam_policy_document" "tenant_table_read_write" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]

    resources = [
      "arn:aws:dynamodb:*:${local.current_account_id}:table/${var.resource_prefix}-tenant-*"
    ]

    sid = "TenantTableAccess"
  }
}

resource "aws_iam_policy" "tenant_table_read_write" {
  description = "IAM permissions to read and write Tenant tables"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-tenant-table-read-write"
  policy      = data.aws_iam_policy_document.tenant_table_read_write.json
}


###############
## ECR- Read ##
###############
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
    ]

    resources = [
      "arn:aws:ecr:${local.current_region}:${local.artifacts_account_id}:repository/*"
    ]

    sid = "ECRAccess"
  }
}

resource "aws_iam_policy" "ecr_read" {
  description = "IAM permissions to get ECR images"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-ecr-read"
  policy      = data.aws_iam_policy_document.ecr_read.json
}
