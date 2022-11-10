locals {
  regional_app_userpool_client_ids = compact(
    [
      one(module.app_cognito_pool_us_east_1[*].client_id),
      one(module.app_cognito_pool_us_east_2[*].client_id),
      one(module.app_cognito_pool_us_west_1[*].client_id),
      one(module.app_cognito_pool_us_west_2[*].client_id),
    ]
  )
  regional_app_userpool_ids = compact(
    [
      one(module.app_cognito_pool_us_east_1[*].userpool_id),
      one(module.app_cognito_pool_us_east_2[*].userpool_id),
      one(module.app_cognito_pool_us_west_1[*].userpool_id),
      one(module.app_cognito_pool_us_west_2[*].userpool_id),
    ]
  )
}

################################
## App Cognito Pool control ##
################################
module "app_cognito_pool_control" {
  app_cognito_pre_authentication_lambda_role_arn = aws_iam_role.app_cognito_pre_authentication_function.arn
  artifacts_bucket                               = "${local.artifacts_bucket_prefix}-${data.aws_region.current.name}"
  dead_letter_arn                                = module.lambda_underpin_control.dead_letter_arn
  environment_variables                          = local.app_api_cognito_pre_authentication_environment_variables
  function_s3_object_key                         = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  kms_key_arn                                    = module.lambda_underpin_control.kms_key_arn
  name                                           = var.resource_prefix
  runtime                                        = local.lambda_runtime
  tags                                           = local.tags

  source = "./modules/app-user-pool"
}

################################
## App Cognito Pool us-east-1 ##
################################
module "app_cognito_pool_us_east_1" {
  count = contains(local.non_control_regions, "us-east-1") == true ? 1 : 0

  app_cognito_pre_authentication_lambda_role_arn = aws_iam_role.app_cognito_pre_authentication_function.arn
  artifacts_bucket                               = "${local.artifacts_bucket_prefix}-us-east-1"
  dead_letter_arn                                = one(module.lambda_underpin_us_east_1[*].dead_letter_arn)
  environment_variables                          = local.app_api_cognito_pre_authentication_environment_variables
  function_s3_object_key                         = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  kms_key_arn                                    = one(module.lambda_underpin_us_east_1[*].kms_key_arn)
  name                                           = var.resource_prefix
  runtime                                        = local.lambda_runtime
  tags                                           = local.tags

  source = "./modules/app-user-pool"

  providers = {
    aws = aws.us-east-1
  }
}

################################
## App Cognito Pool us-east-2 ##
################################
module "app_cognito_pool_us_east_2" {
  count = contains(local.non_control_regions, "us-east-2") == true ? 1 : 0

  app_cognito_pre_authentication_lambda_role_arn = aws_iam_role.app_cognito_pre_authentication_function.arn
  artifacts_bucket                               = "${local.artifacts_bucket_prefix}-us-east-2"
  dead_letter_arn                                = one(module.lambda_underpin_us_east_2[*].dead_letter_arn)
  environment_variables                          = local.app_api_cognito_pre_authentication_environment_variables
  function_s3_object_key                         = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  kms_key_arn                                    = one(module.lambda_underpin_us_east_2[*].kms_key_arn)
  name                                           = var.resource_prefix
  runtime                                        = local.lambda_runtime
  tags                                           = local.tags

  source = "./modules/app-user-pool"

  providers = {
    aws = aws.us-east-2
  }
}


###############################
# App Cognito Pool us-west-1 ##
###############################

module "app_cognito_pool_us_west_1" {
  count = contains(local.non_control_regions, "us-west-1") == true ? 1 : 0

  app_cognito_pre_authentication_lambda_role_arn = aws_iam_role.app_cognito_pre_authentication_function.arn
  artifacts_bucket                               = "${local.artifacts_bucket_prefix}-us-west-1"
  dead_letter_arn                                = one(module.lambda_underpin_us_west_1[*].dead_letter_arn)
  environment_variables                          = local.app_api_cognito_pre_authentication_environment_variables
  function_s3_object_key                         = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  kms_key_arn                                    = one(module.lambda_underpin_us_west_1[*].kms_key_arn)
  name                                           = var.resource_prefix
  runtime                                        = local.lambda_runtime
  tags                                           = local.tags

  source = "./modules/app-user-pool"

  providers = {
    aws = aws.us-west-1
  }
}

###############################
# App Cognito Pool us-west-2 ##
###############################

module "app_cognito_pool_us_west_2" {
  count = contains(local.non_control_regions, "us-west-2") == true ? 1 : 0

  app_cognito_pre_authentication_lambda_role_arn = aws_iam_role.app_cognito_pre_authentication_function.arn
  artifacts_bucket                               = "${local.artifacts_bucket_prefix}-us-west-2"
  dead_letter_arn                                = one(module.lambda_underpin_us_west_2[*].dead_letter_arn)
  environment_variables                          = local.app_api_cognito_pre_authentication_environment_variables
  function_s3_object_key                         = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  kms_key_arn                                    = one(module.lambda_underpin_us_west_2[*].kms_key_arn)
  name                                           = var.resource_prefix
  runtime                                        = local.lambda_runtime
  tags                                           = local.tags

  source = "./modules/app-user-pool"

  providers = {
    aws = aws.us-west-2
  }
}