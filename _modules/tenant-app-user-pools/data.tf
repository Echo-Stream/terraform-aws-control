data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_dynamodb_table" "graph_table" {
  name = var.graph_table_name
}