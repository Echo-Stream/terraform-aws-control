###############################
## General Account Resources ##
###############################
module "log_bucket" {
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
}

resource "aws_kms_alias" "lambda_environment_variables" {
  name          = "alias/${var.resource_prefix}-lambda-environment-variables"
  target_key_id = aws_kms_key.lambda_environment_variables.key_id
}

## Regional Log buckets
module "log_bucket_us_east_1" {
  count        = contains(local.regions, "us-east-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "us-east-1"
  tags         = local.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"

  providers = {
    aws = aws.north-virginia
  }
}

module "log_bucket_us_east_2" {
  count        = contains(local.regions, "us-east-2") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "us-east-2"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.ohio
  }
}

module "log_bucket_us_west_1" {
  count        = contains(local.regions, "us-west-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "us-west-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.north-california
  }
}

module "log_bucket_us_west_2" {
  count        = contains(local.regions, "us-west-2") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "us-west-2"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.oregon
  }
}

####
module "log_bucket_af_south_1" {
  count        = contains(local.regions, "af-south-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "af-south-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.cape-town
  }
}

####
module "log_bucket_ap_east_1" {
  count        = contains(local.regions, "ap-east-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "ap-east-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.hongkong
  }
}

module "log_bucket_ap_south_1" {
  count        = contains(local.regions, "ap-south-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "ap-south-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.mumbai
  }
}

module "log_bucket_ap_northeast_2" {
  count        = contains(local.regions, "ap-northeast-2") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "ap-northeast-2"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.osaka
  }
}

module "log_bucket_ap_southeast_1" {
  count        = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "ap-southeast-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.singapore
  }
}

module "log_bucket_ap_southeast_2" {
  count        = contains(local.regions, "ap-southeast-2") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "ap-southeast-2"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.sydney
  }
}

module "log_bucket_ap_northeast_1" {
  count        = contains(local.regions, "ap-northeast-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "ap-northeast-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.tokyo
  }
}

####
module "log_bucket_ca_central_1" {
  count        = contains(local.regions, "ca-central-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "ca-central-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.central
  }
}

####
module "log_bucket_eu_central_1" {
  count        = contains(local.regions, "eu-central-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "eu-central-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.frankfurt
  }
}

module "log_bucket_eu_west_1" {
  count        = contains(local.regions, "eu-west-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "eu-west-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.ireland
  }
}

module "log_bucket_eu_west_2" {
  count        = contains(local.regions, "eu-west-2") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "eu-west-2"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.london
  }
}

module "log_bucket_eu_south_1" {
  count        = contains(local.regions, "eu-south-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "eu-south-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.milan
  }
}

module "log_bucket_eu_west_3" {
  count        = contains(local.regions, "eu-west-3") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "eu-west-3"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.paris
  }
}

module "log_bucket_eu_north_1" {
  count        = contains(local.regions, "eu-north-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "eu-north-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.stockholm
  }
}

####
module "log_bucket_me_south_1" {
  count        = contains(local.regions, "me-south-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "me-south-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.bahrain
  }
}

####
module "log_bucket_sa_east_1" {
  count        = contains(local.regions, "sa-east-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "sa-east-1"
  source       = "QuiNovas/log-bucket/aws"
  version      = "4.0.0"

  providers = {
    aws = aws.sao-paulo
  }
}