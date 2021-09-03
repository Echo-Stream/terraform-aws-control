resource "aws_sqs_queue" "system_sqs_queue" {
  name                        = "${var.resource_prefix}_system-db-stream.fifo"
  content_based_deduplication = "true"
  fifo_queue                  = true
  tags                        = local.tags
  visibility_timeout_seconds  = 300
}

resource "aws_sqs_queue" "stream_dead_letter_queue" {
  name                        = "${var.resource_prefix}-stream-dead-letter.fifo"
  content_based_deduplication = "true"
  fifo_queue                  = true
  tags                        = local.tags
}