###############################
# App Cognito Pool us-east-2 ##
###############################
module "app_cognito_pool_us_east_2" {
  count = contains(local.regions, "us-east-2") == true ? 1 : 0

  artifacts_bucket       = "${local.artifacts_bucket_prefix}-us-east-2"
  control_region         = local.current_region
  dead_letter_arn        = module.lambda_underpin_us_east_2.dead_letter_arn
  environment            = var.resource_prefix
  function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  graph_table_name       = module.graph_table.name
  kms_key_arn            = module.lambda_underpin_us_east_2.kms_key_arn
  name                   = "${var.resource_prefix}-us-east-2"
  tags                   = local.tags
  tenant_regions         = jsonencode(local.tenant_regions)

  source = "./_modules/tenant-app-user-pool"

  providers = {
    aws = aws.ohio
  }
}

###############################
# App Cognito Pool us-west-1 ##
###############################
module "app_cognito_pool_us_west_1" {
  count = contains(local.regions, "us-west-1") == true ? 1 : 0

  artifacts_bucket       = "${local.artifacts_bucket_prefix}-us-west-1"
  control_region         = local.current_region
  dead_letter_arn        = module.lambda_underpin_us_west_1.dead_letter_arn
  environment            = var.resource_prefix
  function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  graph_table_name       = module.graph_table.name
  kms_key_arn            = module.lambda_underpin_us_west_1.kms_key_arn
  name                   = "${var.resource_prefix}-us-west-1"
  tags                   = local.tags
  tenant_regions         = jsonencode(local.tenant_regions)

  source = "./_modules/tenant-app-user-pool"

  providers = {
    aws = aws.north-california
  }
}