locals {
  region_api_ids = compact(
    [
      one(module.af_south_1).api_id,
      one(module.ap_east_1).api_id,
      one(module.ap_northeast_1).api_id,
      one(module.ap_northeast_2).api_id,
      one(module.ap_south_1).api_id,
      one(module.ap_southeast_1).api_id,
      one(module.ap_southeast_2).api_id,
      one(module.ca_central_1).api_id,
      one(module.eu_central_1).api_id,
      one(module.us_east_1).api_id,
      one(module.us_east_2).api_id,
      one(module.us_west_1).api_id,
      one(module.us_west_2).api_id,
    ]
  )
  region_client_ids = compact(
    [
      one(module.af_south_1).client_id,
      one(module.ap_east_1).client_id,
      one(module.ap_northeast_1).client_id,
      one(module.ap_northeast_2).client_id,
      one(module.ap_south_1).client_id,
      one(module.ap_southeast_1).client_id,
      one(module.ap_southeast_2).client_id,
      one(module.ca_central_1).client_id,
      one(module.eu_central_1).client_id,
      one(module.us_east_1).client_id,
      one(module.us_east_2).client_id,
      one(module.us_west_1).client_id,
      one(module.us_west_2).client_id,
    ]
  )
  region_dead_letter_arns = compact(
    [
      one(module.af_south_1).dead_letter_arn,
      one(module.ap_east_1).dead_letter_arn,
      one(module.ap_northeast_1).dead_letter_arn,
      one(module.ap_northeast_2).dead_letter_arn,
      one(module.ap_south_1).dead_letter_arn,
      one(module.ap_southeast_1).dead_letter_arn,
      one(module.ap_southeast_2).dead_letter_arn,
      one(module.ca_central_1).dead_letter_arn,
      one(module.eu_central_1).dead_letter_arn,
      one(module.us_east_1).dead_letter_arn,
      one(module.us_east_2).dead_letter_arn,
      one(module.us_west_1).dead_letter_arn,
      one(module.us_west_2).dead_letter_arn,
    ]
  )
  region_kms_key_arns = compact(
    [
      one(module.af_south_1).kms_key_arn,
      one(module.ap_east_1).kms_key_arn,
      one(module.ap_northeast_1).kms_key_arn,
      one(module.ap_northeast_2).kms_key_arn,
      one(module.ap_south_1).kms_key_arn,
      one(module.ap_southeast_1).kms_key_arn,
      one(module.ap_southeast_2).kms_key_arn,
      one(module.ca_central_1).kms_key_arn,
      one(module.eu_central_1).kms_key_arn,
      one(module.us_east_1).kms_key_arn,
      one(module.us_east_2).kms_key_arn,
      one(module.us_west_1).kms_key_arn,
      one(module.us_west_2).kms_key_arn,
    ]
  )
  region_userpool_ids = compact(
    [
      one(module.af_south_1).userpool_id,
      one(module.ap_east_1).userpool_id,
      one(module.ap_northeast_1).userpool_id,
      one(module.ap_northeast_2).userpool_id,
      one(module.ap_south_1).userpool_id,
      one(module.ap_southeast_1).userpool_id,
      one(module.ap_southeast_2).userpool_id,
      one(module.ca_central_1).userpool_id,
      one(module.eu_central_1).userpool_id,
      one(module.us_east_1).userpool_id,
      one(module.us_east_2).userpool_id,
      one(module.us_west_1).userpool_id,
      one(module.us_west_2).userpool_id,
    ]
  )
  regions = sort(setsubtract(var.tenant_regions, [data.aws_region.current.name])) # Tenant + Control Regions
}

########################## Africa ######################################

module "af_south_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "af-south-1") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.cape-town
    aws.route-53 = aws.route-53
  }
}

########################## Asia Pacific #################################

module "ap_east_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "ap-east-1") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.hongkong
    aws.route-53 = aws.route-53
  }
}

module "ap_northeast_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "ap-northeast-1") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.tokyo
    aws.route-53 = aws.route-53
  }
}

module "ap_northeast_2" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "ap-northeast-2") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.osaka
    aws.route-53 = aws.route-53
  }
}

module "ap_south_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "ap-south-1") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.mumbai
    aws.route-53 = aws.route-53
  }
}

module "ap_southeast_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "ap-southeast-1") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.singapore
    aws.route-53 = aws.route-53
  }
}

module "ap_southeast_2" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "ap-southeast-2") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.sydney
    aws.route-53 = aws.route-53
  }
}

######################### Canada ###################################

module "ca_central_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "ca-central-1") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  schema                                                = data.aws_s3_object.graphql_schema.body
  resource_prefix                                       = var.resource_prefix
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.central
    aws.route-53 = aws.route-53
  }
}

######################### Europe ##################################

module "eu_central_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "eu-central-1") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  schema                                                = data.aws_s3_object.graphql_schema.body
  resource_prefix                                       = var.resource_prefix
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.frankfurt
    aws.route-53 = aws.route-53
  }
}

############################ United States ######################################

module "us_east_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "us-east-1") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  schema                                                = data.aws_s3_object.graphql_schema.body
  resource_prefix                                       = var.resource_prefix
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.north-virginia
    aws.route-53 = aws.route-53
  }
}

module "us_east_2" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "us-east-2") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.ohio
    aws.route-53 = aws.route-53
  }
}

module "us_west_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "us-west-1") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.north-california
    aws.route-53 = aws.route-53
  }
}

module "us_west_2" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "us-west-2") == true ? 1 : 0

  app_cognito_pre_authentication_environment_variables  = local.app_api_cognito_pre_authentication_environment_variables
  app_cognito_pre_authentication_function_s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  app_cognito_pre_authentication_lambda_role_arn        = aws_iam_role.app_cognito_pre_authentication_function.arn
  appsync_datasource_function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  appsync_datasource_lambda_role_arn                    = module.appsync_datasource_lambda.role_arn
  appsync_service_role_arn                              = module.appsync_datasource.role_arn
  artifacts_bucket_prefix                               = local.artifacts_bucket_prefix
  audit_firehose_log_group                              = local.audit_firehose_log_group
  common_lambda_environment_variables                   = local.common_lambda_environment_variables
  lambda_runtime                                        = local.lambda_runtime
  regional_api_acm_arns                                 = local.regional_api_acm_arns
  regional_domain_names                                 = local.regional_domain_names
  resource_prefix                                       = var.resource_prefix
  schema                                                = data.aws_s3_object.graphql_schema.body
  tags                                                  = local.tags
  zone_id                                               = data.aws_route53_zone.root_domain.zone_id

  source = "./modules/tenant-region"

  providers = {
    aws          = aws.oregon
    aws.route-53 = aws.route-53
  }
}

