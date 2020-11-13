# AWS Provider for user-provided region
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = var.region
}

# us-east-1 (Aliased) aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-east-1"
  alias               = "us-east-1"
}

# us-east-2 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-east-2"
  alias               = "us-east-2"
}

# us-west-1 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-west-1"
  alias               = "us-west-1"
}

# us-west-2 aws provider
provider "aws" {
  allowed_account_ids = [var.allowed_account_id]
  region              = "us-west-2"
  alias               = "us-west-2"
}

###############################
## General Account Resources ##
###############################
module "log_bucket" {
  name_prefix = var.environment_prefix
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.1"
}

## Regional Log buckets
module "log_bucket_us_east_1" {
  count       = contains(local.regions, "us-east-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-us-east-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.1"

  providers = {
    aws = aws.us-east-1
  }
}

module "log_bucket_us_east_2" {
  count       = contains(local.regions, "us-east-2") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-us-east-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.1"

  providers = {
    aws = aws.us-east-2
  }
}

module "log_bucket_us_west_1" {
  count       = contains(local.regions, "us-west-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-us-west-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.1"

  providers = {
    aws = aws.us-west-1
  }
}

module "log_bucket_us_west_2" {
  count       = contains(local.regions, "us-west-2") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-us-west-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.1"

  providers = {
    aws = aws.us-west-2
  }
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