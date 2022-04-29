module "lambda_underpin_us_east_2" {
  name = var.resource_prefix
  tags = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.ohio
  }
}

module "lambda_underpin_us_west_1" {
  name = var.resource_prefix
  tags = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.north-california
  }
}

module "lambda_underpin_us_west_2" {
  name = var.resource_prefix
  tags = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.oregon
  }
}