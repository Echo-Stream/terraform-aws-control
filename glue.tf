resource "aws_glue_catalog_database" "billing" {
  description = "Primary database for echostream billing. It has Cost/Usage, ManagedInstances tables"
  name        = "${var.resource_prefix}-billing"
}