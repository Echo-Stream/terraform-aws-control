# Default us-east-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = var.region
  version             = "3.6.0"
}

# us-east-2 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-east-2"
  version             = "3.6.0"
  alias               = "us-east-2"
}

# us-west-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-west-1"
  version             = "3.6.0"
  alias               = "us-west-1"
}

###############################
## General Account Resources ##
###############################
module "log_bucket" {
  name_prefix = var.environment_prefix
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.1"
}

resource "aws_sns_topic" "lambda_dead_letter" {
  display_name = "${var.environment_prefix}-lambda-dead-letter"
  name         = "${var.environment_prefix}-lambda-dead-letter"
  tags         = local.tags
}

resource "aws_kms_key" "lambda_environment_variables" {
  description         = "Lambda environment variable key for ${var.environment_prefix}"
  enable_key_rotation = true
}

resource "aws_kms_alias" "lambda_environment_variables" {
  name          = "alias/${var.environment_prefix}-lambda-environment-variables"
  target_key_id = aws_kms_key.lambda_environment_variables.key_id
}