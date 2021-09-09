###########################
#  process-audit-record  ##
###########################
module "process_audit_record" {
  description = "Processes a message audit record as it passes through the firehose"

  environment_variables = {
    APP_CLIENT_ID   = aws_cognito_user_pool_client.echostream_apps_userpool_client.id
    ENVIRONMENT     = var.resource_prefix
    ID_TOKEN_KEY    = local.id_token_key
    USERPOOL_ID     = aws_cognito_user_pool.echostream_apps.id
    USERPOOL_REGION = local.current_region
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.resource_prefix}-process-audit-record"
  runtime         = "python3.9"
  s3_bucket       = local.artifacts_bucket
  s3_object_key   = local.lambda_functions_keys["process_audit_record"]
  source          = "QuiNovas/lambda/aws"
  tags            = local.tags
  timeout         = 300
  version         = "3.0.14"
}

resource "aws_cloudwatch_log_subscription_filter" "process_audit_record" {
  name            = "${var.resource_prefix}-process-audit-record"
  log_group_name  = module.process_audit_record.log_group_name
  filter_pattern  = "ERROR -USERERROR"
  destination_arn = module.control_alert_handler.arn
}

resource "aws_cloudwatch_log_group" "process_audit_record_firehose" {
  name              = "/aws/kinesisfirehose/${var.resource_prefix}-process-audit-record-firehose"
  retention_in_days = 7
  tags              = local.tags
}

resource "aws_cloudwatch_log_stream" "process_audit_record_firehose" {
  log_group_name = aws_cloudwatch_log_group.process_audit_record_firehose.name
  name           = "S3Delivery"
}

resource "aws_iam_role" "process_audit_record_firehose" {
  description        = "Write Transformed audit records into the bucket"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
  name               = "${var.resource_prefix}-process-audit-record-firehose"
  tags               = local.tags
}

data "aws_iam_policy_document" "process_audit_record_firehose" {
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
      aws_cloudwatch_log_stream.process_audit_record_firehose.arn,
    ]

    sid = "AllowWritingErrorEvents"
  }

  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      "${module.process_audit_record.arn}:$LATEST",
    ]

    sid = "InvokeFunction"
  }
}

resource "aws_iam_role_policy" "process_audit_record_firehose" {
  name   = "${var.resource_prefix}-process-audit-record-firehose-access"
  policy = data.aws_iam_policy_document.process_audit_record_firehose.json
  role   = aws_iam_role.process_audit_record_firehose.id
}

resource "aws_kinesis_firehose_delivery_stream" "process_audit_record_firehose" {
  destination = "extended_s3"
  name        = "${var.resource_prefix}-process-audit-record"

  extended_s3_configuration {
    bucket_arn      = aws_s3_bucket.audit_records.arn
    buffer_interval = 900
    buffer_size     = 128

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.process_audit_record_firehose.name
      log_stream_name = aws_cloudwatch_log_stream.process_audit_record_firehose.name
    }

    error_output_prefix = "errors/"
    prefix              = "current/year=!{timestamp:yyyy}/month=!{timestamp:MM}/"

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${module.process_audit_record.arn}:$LATEST"
        }
      }
    }

    compression_format = "GZIP"
    role_arn           = aws_iam_role.process_audit_record_firehose.arn
  }

  tags = local.tags
}
