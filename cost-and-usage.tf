resource "aws_bcmdataexports_export" "cost_and_usage" {
  depends_on  = [aws_s3_bucket_policy.cost_and_usage]
  description = "EchoStream Billing Exports"

  export {
    data_query {
      query_statement = "SELECT * FROM COST_AND_USAGE_REPORT"
      table_configurations = {
        COST_AND_USAGE_REPORT = {
          INCLUDE_MANUAL_DISCOUNT_COMPATIBILITY = "FALSE",
          INCLUDE_RESOURCES                     = "TRUE",
          INCLUDE_SPLIT_COST_ALLOCATION_DATA    = "FALSE",
          TIME_GRANULARITY                      = "MONTHLY",
        }
      }
    }

    destination_configurations {
      s3_destination {
        s3_bucket = aws_s3_bucket.cost_and_usage.id

        s3_output_configurations {
          compression = "PARQUET"
          format      = "PARQUET"
          output_type = "CUSTOM"
          overwrite   = "OVERWRITE_REPORT"
        }

        s3_prefix = "exports"
        s3_region = aws_s3_bucket.cost_and_usage.region
      }
    }

    name = "CostAndUsage"

    refresh_cadence {
      frequency = "SYNCHRONOUS"
    }
  }
}

resource "aws_s3_bucket" "cost_and_usage" {
  bucket = "${var.resource_prefix}-cost-and-usage"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}

resource "aws_s3_bucket_acl" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    id     = "cost-and-usage-cleanup"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_logging" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id

  target_bucket = local.log_bucket
  target_prefix = "${var.resource_prefix}-cost-and-usage/"
}

data "aws_iam_policy_document" "cost_and_usage" {
  statement {
    actions = [
      "s3:GetBucketPolicy",
      "s3:PutObject"
    ]
    condition {
      test = "StringLike"
      values = [
        aws_caller_identity.current.account_id,
      ]
      variable = "aws:SourceAccount"
    }
    condition {
      test = "StringLike"
      values = [
        "arn:aws:bcm-data-exports:us-east-1:${aws_caller_identity.current.account_id}:export/*",
        "arn:aws:cur:us-east-1:${aws_caller_identity.current.account_id}:definition/*",
      ]
      variable = "aws:SourceArn"
    }
    effect = "Allow"
    principals {
      identifiers = [
        "bcm-data-exports.amazonaws.com",
        "billingreports.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      aws_s3_bucket.cost_and_usage.arn,
      "${aws_s3_bucket.cost_and_usage.arn}/*",
    ]
    sid = "CostAndUsageReports"
  }
}

resource "aws_s3_bucket_policy" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id
  policy = data.aws_iam_policy_document.cost_and_usage.json
}

resource "aws_s3_bucket_public_access_block" "cost_and_usage" {
  bucket                  = aws_s3_bucket.cost_and_usage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "cost_and_usage" {
  bucket = aws_s3_bucket.cost_and_usage.id
  versioning_configuration {
    status = "Enabled"
  }
}

## CUR Report Definition ##
/*
resource "aws_cur_report_definition" "cost_and_usage" {
  depends_on                 = [aws_s3_bucket_policy.cost_and_usage]
  additional_schema_elements = ["RESOURCES"]
  compression                = "Parquet"
  format                     = "Parquet"
  refresh_closed_reports     = true
  report_name                = "CostAndUsage"
  report_versioning          = "OVERWRITE_REPORT"
  s3_prefix                  = "reports"
  # Can't leave S3 prefix empty if Definition is integrated with Athena
  # If s3_prefix is empty, AWS is making ReportPathPrefix = /<report_name>
  # so final reports are put under /<report_name>/<report_name>
  # Example, lets say our report-name = "CostAndUsage". The S3 path would be s3://<bucket-name>//CostAndUsage/CostAndUsage/<reports>
  # better to include some prefix, to make it look cleaner (avoids leading slash)
  # for e.g if prefix is set to 'echo'. The s3 path would look like s3://<bucket-name>/echo/CostAndUsage/CostAndUsage/<reports>
  s3_bucket = aws_s3_bucket.cost_and_usage.id
  s3_region = data.aws_region.current.name
  time_unit = "DAILY"

  provider = aws.us-east-1
}
*/
