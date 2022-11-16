locals {
  regional_kms_key_arns = compact(
    [
      module.lambda_underpin_control.kms_key_arn,
      one(module.lambda_underpin_us_east_1[*].kms_key_arn),
      one(module.lambda_underpin_us_east_2[*].kms_key_arn),
      one(module.lambda_underpin_us_west_1[*].kms_key_arn),
      one(module.lambda_underpin_us_west_2[*].kms_key_arn),
    ]
  )
  regional_dead_letter_arns = compact(
    [
      module.lambda_underpin_control.dead_letter_arn,
      one(module.lambda_underpin_us_east_1[*].dead_letter_arn),
      one(module.lambda_underpin_us_east_2[*].dead_letter_arn),
      one(module.lambda_underpin_us_west_1[*].dead_letter_arn),
      one(module.lambda_underpin_us_west_2[*].dead_letter_arn),
    ]
  )
}


module "lambda_underpin_control" {
  resource_prefix = var.resource_prefix
  support_email   = data.aws_ses_email_identity.support.email
  tags            = local.tags

  source = "./modules/lambda-underpin"
}

module "lambda_underpin_us_east_1" {
  count = contains(local.non_control_regions, "us-east-1") == true ? 1 : 0

  resource_prefix = var.resource_prefix
  support_email   = data.aws_ses_email_identity.support.email
  tags            = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.us-east-1
  }
}

module "lambda_underpin_us_east_2" {
  count = contains(local.non_control_regions, "us-east-2") == true ? 1 : 0

  resource_prefix = var.resource_prefix
  support_email   = data.aws_ses_email_identity.support.email
  tags            = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.us-east-2
  }
}

module "lambda_underpin_us_west_1" {
  count = contains(local.non_control_regions, "us-west-1") == true ? 1 : 0

  resource_prefix = var.resource_prefix
  support_email   = data.aws_ses_email_identity.support.email
  tags            = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.us-west-1
  }
}

module "lambda_underpin_us_west_2" {
  count = contains(local.non_control_regions, "us-west-2") == true ? 1 : 0

  resource_prefix = var.resource_prefix
  support_email   = data.aws_ses_email_identity.support.email
  tags            = local.tags

  source = "./modules/lambda-underpin"

  providers = {
    aws = aws.us-west-2
  }
}