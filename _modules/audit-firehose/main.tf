resource "aws_cloudwatch_log_group" "audit_records" {
  name              = "/aws/kinesisfirehose/${var.resource_prefix}-audit-records"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_cloudwatch_log_stream" "audit_records" {
  log_group_name = aws_cloudwatch_log_group.audit_records.name
  name           = "S3Delivery"
}

resource "aws_iam_role" "audit_records" {
  description        = "Write Transformed audit records into the bucket"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
  name               = "${var.resource_prefix}-audit-records-${var.region}"
  tags               = var.tags
}

data "aws_iam_policy_document" "audit_records" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.audit_records.arn}/*",
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
      aws_s3_bucket.audit_records.arn,
    ]

    sid = "AllowBucketOperations"
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_stream.audit_records.arn,
    ]

    sid = "AllowWritingErrorEvents"
  }
}

resource "aws_iam_role_policy" "audit_records" {
  name   = "${var.resource_prefix}-audit-records-${var.region}"
  policy = data.aws_iam_policy_document.audit_records.json
  role   = aws_iam_role.audit_records.id
}

resource "aws_kinesis_firehose_delivery_stream" "audit_records" {
  destination = "extended_s3"
  name        = "${var.resource_prefix}-audit-records"

  extended_s3_configuration {
    bucket_arn      = aws_s3_bucket.audit_records.arn
    buffer_interval = 900
    buffer_size     = 128

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.audit_records.name
      log_stream_name = aws_cloudwatch_log_stream.audit_records.name
    }

    error_output_prefix = "errors/"
    prefix              = "current/year=!{timestamp:yyyy}/month=!{timestamp:MM}/"
    compression_format  = "GZIP"
    role_arn            = aws_iam_role.audit_records.arn
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }
  tags = var.tags
}

# SNS
resource "aws_iam_role" "audit_records_subscription" {
  description        = "Allows Audit records SNS topic to be subscribed to Audit records Firehose"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
  name               = "${var.resource_prefix}-audit-records-subscription-${var.region}"
  tags               = var.tags
}

data "aws_iam_policy_document" "audit_records_subscription" {
  statement {
    actions = [
      "firehose:DescribeDeliveryStream",
      "firehose:ListDeliveryStreams",
      "firehose:ListTagsForDeliveryStream",
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]

    resources = [
      aws_kinesis_firehose_delivery_stream.audit_records.arn
    ]

    sid = "AllowSNSSubsctiption"
  }
}

resource "aws_iam_role_policy" "audit_records_subscription" {
  name   = "${var.resource_prefix}-audit-records-subscription-${var.region}"
  policy = data.aws_iam_policy_document.audit_records_subscription.json
  role   = aws_iam_role.audit_records_subscription.id
}

resource "aws_sns_topic" "audit_records" {
  display_name      = "Audit Records"
  kms_master_key_id = "alias/aws/sns"
  name              = "${var.resource_prefix}-audit-records"
  tags              = var.tags
}


resource "aws_sns_topic_subscription" "audit_records" {
  endpoint              = aws_kinesis_firehose_delivery_stream.audit_records.arn
  subscription_role_arn = aws_iam_role.audit_records_subscription.arn
  protocol              = "firehose"
  raw_message_delivery  = true
  topic_arn             = aws_sns_topic.audit_records.arn
}
