###############################
## General Account Resources ##
###############################
module "log_bucket_control" {
  name_prefix = var.resource_prefix
  tags        = local.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"
}

resource "aws_sns_topic" "lambda_dead_letter" {
  display_name = "${var.resource_prefix}-lambda-dead-letter"
  name         = "${var.resource_prefix}-lambda-dead-letter"
  tags         = local.tags
}

resource "aws_kms_key" "lambda_environment_variables" {
  description         = "Lambda environment variable key for ${var.resource_prefix}"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_kms_alias" "lambda_environment_variables" {
  name          = "alias/${var.resource_prefix}-lambda-environment-variables"
  target_key_id = aws_kms_key.lambda_environment_variables.key_id
}

resource "aws_iam_service_linked_role" "dynamo_db_replication" {
  count            = var.create_dynamo_db_replication_service_role ? 1 : 0
  aws_service_name = "replication.dynamodb.amazonaws.com"
}

module "log_bucket" {
  name_prefix  = var.resource_prefix
  name_postfix = data.aws_region.current.name
  tags         = local.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"
}
