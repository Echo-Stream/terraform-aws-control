
resource "aws_sqs_queue" "system_sqs_queue" {
  content_based_deduplication = "true"
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
  name                        = "${var.resource_prefix}-system-db-stream.fifo"
  visibility_timeout_seconds  = 900

  tags = local.tags
}

resource "aws_sqs_queue" "stream_dead_letter_queue" {
  content_based_deduplication = "true"
  fifo_queue                  = true
  name                        = "${var.resource_prefix}-stream-dead-letter.fifo"

  tags = local.tags
}

resource "aws_sqs_queue" "managed_app_cloud_init" {
  content_based_deduplication = "true"
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
  name                        = "${var.resource_prefix}-managed-app-cloud-init.fifo"
  visibility_timeout_seconds  = 900

  tags = local.tags
}

resource "aws_sqs_queue" "record_cloudwatch_alarm" {
  content_based_deduplication = "true"
  delay_seconds               = 300
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
  name                        = "${var.resource_prefix}-record-cloudwatch-alarm.fifo"
  visibility_timeout_seconds  = 900

  tags = local.tags
}

resource "aws_sqs_queue" "record_tenant" {
  content_based_deduplication = "true"
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
  name                        = "${var.resource_prefix}-record-tenant.fifo"
  visibility_timeout_seconds  = 900

  tags = local.tags
}
