## US-EAST-1
module "audit_firehose_us_east_1" {
  count           = contains(local.regions, "us-east-1") == true ? 1 : 0
  log_bucket      = module.log_bucket_us_east_1.0.id
  region          = "us-east-1"
  resource_prefix = var.resource_prefix
  tags            = local.tags
  source          = "./_modules/audit-firehose"

  providers = {
    aws = aws.north-virginia
  }
}

## US-EAST-2
module "audit_firehose_us_east_2" {
  count           = contains(local.regions, "us-east-2") == true ? 1 : 0
  log_bucket      = module.log_bucket_us_east_2.0.id
  region          = "us-east-2"
  resource_prefix = var.resource_prefix
  tags            = local.tags
  source          = "./_modules/audit-firehose"

  providers = {
    aws = aws.ohio
  }
}

## US-WEST-1
module "audit_firehose_us_west_1" {
  count           = contains(local.regions, "us-west-1") == true ? 1 : 0
  log_bucket      = module.log_bucket_us_west_2.0.id
  region          = "us-west-1"
  resource_prefix = var.resource_prefix
  tags            = local.tags
  source          = "./_modules/audit-firehose"

  providers = {
    aws = aws.north-california
  }
}

## US-WEST-2
module "audit_firehose_us_west_2" {
  count           = contains(local.regions, "us-west-2") == true ? 1 : 0
  log_bucket      = module.log_bucket_us_west_2.0.id
  region          = "us-west-2"
  resource_prefix = var.resource_prefix
  tags            = local.tags
  source          = "./_modules/audit-firehose"

  providers = {
    aws = aws.oregon
  }
}