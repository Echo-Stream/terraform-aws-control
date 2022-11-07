locals {
  regional_kms_key_arns = compact(
    [
      module.lambda_underpin_control.kms_key_arn,
      one(module.lambda_underpin_us_east_1).kms_key_arn,
      one(module.lambda_underpin_us_east_2).kms_key_arn,
      one(module.lambda_underpin_us_west_1).kms_key_arn,
      one(module.lambda_underpin_us_west_2).kms_key_arn,
    ]
  )
  regional_dead_letter_arns = compact(
    [
      module.lambda_underpin_control.dead_letter_arn,
      one(module.lambda_underpin_us_east_1).dead_letter_arn,
      one(module.lambda_underpin_us_east_2).dead_letter_arn,
      one(module.lambda_underpin_us_west_1).dead_letter_arn,
      one(module.lambda_underpin_us_west_2).dead_letter_arn,
    ]
  )
}


module "lambda_underpin_control" {
  name = var.resource_prefix
  tags = local.tags

  source = "./modules/lambda-underpin"
}

module "lambda_underpin_us_east_1" {
  count      = contains(local.regions, "us-east-1") == true ? 1 : 0

  name = var.resource_prefix
  tags = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.north-virginia
  }
}

module "lambda_underpin_us_east_2" {
  count      = contains(local.regions, "us-east-2") == true ? 1 : 0

  name = var.resource_prefix
  tags = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.ohio
  }
}

module "lambda_underpin_us_west_1" {
  count      = contains(local.regions, "us-west-1") == true ? 1 : 0

  name = var.resource_prefix
  tags = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.north-california
  }
}

module "lambda_underpin_us_west_2" {
  count      = contains(local.regions, "us-west-2") == true ? 1 : 0

  name = var.resource_prefix
  tags = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.oregon
  }
}