resource "aws_s3_bucket" "cost_and_usage" {
  bucket = "${var.resource_prefix}-cost-and-usage"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}

resource "aws_s3_bucket_logging" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id

  target_bucket = local.log_bucket
  target_prefix = "${var.resource_prefix}-cost-and-usage/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cost_and_usage" {
  bucket                  = aws_s3_bucket.cost_and_usage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "cost_and_usage" {
  statement {
    actions = [
      "s3:*",
    ]
    condition {
      test = "Bool"
      values = [
        "false",
      ]
      variable = "aws:SecureTransport"
    }
    effect = "Deny"
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
    resources = [
      aws_s3_bucket.cost_and_usage.arn,
      "${aws_s3_bucket.cost_and_usage.arn}/*",
    ]
    sid = "DenyUnsecuredTransport"
  }

  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy",
      "s3:PutObject"
    ]
    effect = "Allow"
    principals {
      identifiers = [
        "billingreports.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      aws_s3_bucket.cost_and_usage.arn,
      "${aws_s3_bucket.cost_and_usage.arn}/*",
    ]
    sid = "Billing Reports"
  }
}

resource "aws_s3_bucket_policy" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id
  policy = data.aws_iam_policy_document.cost_and_usage.json
}

## CUR Report Definition ##
resource "aws_cur_report_definition" "cost_and_usage" {
  additional_schema_elements = ["RESOURCES"]
  compression                = "Parquet"
  format                     = "Parquet"
  refresh_closed_reports     = true
  report_name                = "CostAndUsage"
  report_versioning          = "OVERWRITE_REPORT"

  s3_bucket = aws_s3_bucket.cost_and_usage.id
  s3_region = local.current_region
  time_unit = "DAILY"
}

resource "aws_cur_report_definition" "cost_and_usage_test" {
  additional_artifacts       = ["ATHENA"]
  additional_schema_elements = ["RESOURCES"]
  compression                = "Parquet"
  format                     = "Parquet"
  refresh_closed_reports     = true
  report_name                = "CostAndUsage_test"
  report_versioning          = "OVERWRITE_REPORT"
  s3_bucket                  = aws_s3_bucket.cost_and_usage.id
  s3_prefix                  = "test"
  s3_region                  = local.current_region
  time_unit                  = "HOURLY"
}