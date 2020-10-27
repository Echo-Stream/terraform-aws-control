resource "aws_sqs_queue" "default_tenant_sqs_queue" {
  name                        = "${var.environment_prefix}_db-stream_DEFAULT_TENANT.fifo"
  content_based_deduplication = "true"
  fifo_queue                  = true
  tags                        = local.tags
}

resource "aws_sqs_queue" "stream_dead_letter_queue" {
  name                        = "${var.environment_prefix}-stream-dead-letter.fifo"
  content_based_deduplication = "true"
  fifo_queue                  = true
  tags                        = local.tags
}