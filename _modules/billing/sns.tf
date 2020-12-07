resource "aws_sns_topic" "tenant_usage_executions" {
  name         = "${var.environment_prefix}-tenant-usage-executions"
  display_name = "${var.environment_prefix} Tenant Usage Executions"
  tags         = var.tags
}