resource "aws_s3_bucket" "athena_query_results" {
  bucket = "${var.resource_prefix}-athena-query-results"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}

resource "aws_s3_bucket_logging" "athena_query_results" {
  bucket        = aws_s3_bucket.athena_query_results.id
  target_bucket = local.log_bucket
  target_prefix = "${var.resource_prefix}-athena-query-results/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_query_results" {
  bucket = aws_s3_bucket.athena_query_results.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "athena_query_results" {
  bucket = aws_s3_bucket.athena_query_results.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "athena_query_results" {
  bucket                  = aws_s3_bucket.athena_query_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "athena_query_results" {
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
      aws_s3_bucket.athena_query_results.arn,
      "${aws_s3_bucket.athena_query_results.arn}/*",
    ]
    sid = "DenyUnsecuredTransport"
  }
}

resource "aws_s3_bucket_policy" "athena_query_results" {
  bucket = aws_s3_bucket.athena_query_results.id
  policy = data.aws_iam_policy_document.athena_query_results.json
}

resource "aws_athena_workgroup" "echostream" {
  name = var.resource_prefix

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_query_results.bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}