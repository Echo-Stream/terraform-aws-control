resource "aws_iam_role" "audit_firehose" {
  name               = "${var.resource_prefix}-audit-firehose"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
  tags               = local.tags
}

data "aws_iam_policy_document" "audit_firehose" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::tenant-*/audit-records/*",
    ]

    sid = "AllowIntermediateBucketAccess"
  }

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]

    resources = [
      "arn:aws:s3:::tenant-*",
    ]

    sid = "AllowBucketOperations"
  }

  statement {
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    sid = "EncryptDataUsingTenantKeys"
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:${local.audit_firehose_log_group}:log-stream:tenant-*",
    ]

    sid = "AllowWritingErrorEvents"
  }
}

resource "aws_iam_role_policy" "audit_firehose" {
  name   = "${var.resource_prefix}-audit-firehose"
  policy = data.aws_iam_policy_document.audit_firehose.json
  role   = aws_iam_role.audit_firehose.id
}

####################################
# Create log groups in each region #
####################################

resource "aws_cloudwatch_log_group" "audit_firehose_us_east_1" {
  name              = local.audit_firehose_log_group
  retention_in_days = 7
  tags              = var.tags
  provider          = aws.north-virginia
}

resource "aws_cloudwatch_log_group" "audit_firehose_us_east_2" {
  name              = local.audit_firehose_log_group
  retention_in_days = 7
  tags              = var.tags
  provider          = aws.ohio
}

resource "aws_cloudwatch_log_group" "audit_firehose_us_west_1" {
  name              = local.audit_firehose_log_group
  retention_in_days = 7
  tags              = var.tags
  provider          = aws.north-california
}

resource "aws_cloudwatch_log_group" "audit_firehose_us_west_2" {
  name              = local.audit_firehose_log_group
  retention_in_days = 7
  tags              = var.tags
  provider          = aws.oregon
}

# resource "aws_cloudwatch_log_group" "audit_firehose_eu_west_1" {
#   name              = local.audit_firehose_log_group
#   retention_in_days = 7
#   tags              = var.tags
#   provider          = aws.ireland
# }
