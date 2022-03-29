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