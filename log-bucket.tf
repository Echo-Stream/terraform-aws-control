## Regional Log buckets
module "log_bucket_control" {
  name_prefix  = var.resource_prefix
  name_postfix = data.aws_region.current.name
  tags         = local.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"
}

module "log_bucket_us_east_1" {
  count        = contains(local.non_control_regions, "us-east-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "us-east-1"
  tags         = local.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"

  providers = {
    aws = aws.us-east-1
  }
}

module "log_bucket_us_east_2" {
  count        = contains(local.non_control_regions, "us-east-2") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "us-east-2"
  tags         = local.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"

  providers = {
    aws = aws.us-east-2
  }
}

module "log_bucket_us_west_1" {
  count        = contains(local.non_control_regions, "us-west-1") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "us-west-1"
  tags         = local.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"

  providers = {
    aws = aws.us-west-1
  }
}

module "log_bucket_us_west_2" {
  count        = contains(local.non_control_regions, "us-west-2") == true ? 1 : 0
  name_prefix  = var.resource_prefix
  name_postfix = "us-west-2"
  tags         = local.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"

  providers = {
    aws = aws.us-west-2
  }
}
