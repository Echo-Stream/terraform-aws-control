resource "aws_sqs_queue" "default_tenant_sqs_queue" {
  name       = "${var.environment_prefix}_db-stream_DEFAULT_TENANT.fifo"
  fifo_queue = true
  tags       = local.tags
}