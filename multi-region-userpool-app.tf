################################
## App Cognito Pool us-east-1 ##
################################
module "app_cognito_pool_us_east_1" {
  count = contains(local.regions, "us-east-1") == true ? 1 : 0

  app_cognito_pre_authentication_lambda_role_arn = aws_iam_role.app_cognito_pre_authentication_function.arn
  artifacts_bucket                               = "${local.artifacts_bucket_prefix}-us-east-1"
  control_region                                 = local.current_region
  dead_letter_arn                                = aws_sns_topic.lambda_dead_letter.arn
  environment                                    = var.resource_prefix
  function_s3_object_key                         = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  graph_table_name                               = module.graph_table.name
  kms_key_arn                                    = aws_kms_key.lambda_environment_variables.arn
  name                                           = var.resource_prefix
  tags                                           = local.tags
  tenant_region                                  = "us-east-1"
  tenant_regions                                 = jsonencode(local.tenant_regions)

  source = "./_modules/app-user-pool"

  providers = {
    aws = aws.north-virginia
  }
}

################################
## App Cognito Pool us-east-2 ##
################################
module "app_cognito_pool_us_east_2" {
  count = contains(local.regions, "us-east-2") == true ? 1 : 0

  app_cognito_pre_authentication_lambda_role_arn = aws_iam_role.app_cognito_pre_authentication_function.arn
  artifacts_bucket                               = "${local.artifacts_bucket_prefix}-us-east-2"
  control_region                                 = local.current_region
  dead_letter_arn                                = module.lambda_underpin_us_east_2.dead_letter_arn
  environment                                    = var.resource_prefix
  function_s3_object_key                         = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  graph_table_name                               = module.graph_table.name
  kms_key_arn                                    = module.lambda_underpin_us_east_2.kms_key_arn
  name                                           = var.resource_prefix
  tags                                           = local.tags
  tenant_region                                  = "us-east-2"
  tenant_regions                                 = jsonencode(local.tenant_regions)

  source = "./_modules/app-user-pool"

  providers = {
    aws = aws.ohio
  }
}


# ###############################
# # App Cognito Pool us-west-1 ##
# ###############################
# module "app_cognito_pool_us_west_1" {
#   count = contains(local.regions, "us-west-1") == true ? 1 : 0

#   app_cognito_pre_authentication_iam_policy_arn = aws_iam_policy.app_api_cognito_pre_authentication.arn
#   artifacts_bucket                              = "${local.artifacts_bucket_prefix}-us-west-1"
#   control_region                                = local.current_region
#   dead_letter_arn                               = module.lambda_underpin_us_west_1.dead_letter_arn
#   environment                                   = var.resource_prefix
#   function_s3_object_key                        = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
#   graph_ddb_read_iam_policy_arn                 = aws_iam_policy.graph_ddb_read.arn
#   graph_table_name                              = module.graph_table.name
#   kms_key_arn                                   = module.lambda_underpin_us_west_1.kms_key_arn
#   name                                          = var.resource_prefix
#   tags                                          = local.tags
#   tenant_region                                 = "us-west-1"
#   tenant_regions                                = jsonencode(local.tenant_regions)

#   source = "./_modules/app-user-pool"

#   providers = {
#     aws = aws.north-california
#   }
# }


# ###############################
# # App Cognito Pool us-west-2 ##
# ###############################
# module "app_cognito_pool_us_west_2" {
#   count = contains(local.regions, "us-west-2") == true ? 1 : 0

#   app_cognito_pre_authentication_iam_policy_arn = aws_iam_policy.app_api_cognito_pre_authentication.arn
#   artifacts_bucket                              = "${local.artifacts_bucket_prefix}-us-west-2"
#   control_region                                = local.current_region
#   dead_letter_arn                               = module.lambda_underpin_us_west_2.dead_letter_arn
#   environment                                   = var.resource_prefix
#   function_s3_object_key                        = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
#   graph_ddb_read_iam_policy_arn                 = aws_iam_policy.graph_ddb_read.arn
#   graph_table_name                              = module.graph_table.name
#   kms_key_arn                                   = module.lambda_underpin_us_west_2.kms_key_arn
#   name                                          = var.resource_prefix
#   tags                                          = local.tags
#   tenant_region                                 = "us-west-2"
#   tenant_regions                                = jsonencode(local.tenant_regions)

#   source = "./_modules/app-user-pool"

#   providers = {
#     aws = aws.oregon
#   }
# }