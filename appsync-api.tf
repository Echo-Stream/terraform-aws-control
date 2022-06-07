## Control Region

####################
## GraphQL Schema ##
####################

data "aws_s3_object" "graphql_schema" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/schema.graphql"
}

resource "aws_appsync_graphql_api" "echostream" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.echostream_appsync.arn
    field_log_level          = "ERROR"
  }

  user_pool_config {
    default_action = "ALLOW"
    user_pool_id   = aws_cognito_user_pool.echostream_api.id
  }

  additional_authentication_provider {
    authentication_type = "AMAZON_COGNITO_USER_POOLS"

    user_pool_config {
      user_pool_id = aws_cognito_user_pool.echostream_ui.id
    }
  }

  additional_authentication_provider {
    authentication_type = "AMAZON_COGNITO_USER_POOLS"

    user_pool_config {
      user_pool_id = module.app_cognito_pool_us_east_1.0.userpool_id
    }
  }

  schema = data.aws_s3_object.graphql_schema.body

  xray_enabled = false
  name         = "${var.resource_prefix}-api"
  tags         = local.tags
}

resource "aws_iam_role" "echostream_appsync" {
  name               = "${var.resource_prefix}-appsync"
  assume_role_policy = data.aws_iam_policy_document.appsync_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "echostream_appsync" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
  role       = aws_iam_role.echostream_appsync.name
}

resource "aws_appsync_domain_name" "echostream_appsync" {
  depends_on      = [aws_acm_certificate_validation.regional_api]
  domain_name     = lookup(local.regional_apis["domains"], var.region, "")
  certificate_arn = lookup(local.regional_apis["acm_arns"], var.region, "")
}

resource "aws_appsync_domain_name_api_association" "echostream_appsync" {
  api_id      = aws_appsync_graphql_api.echostream.id
  domain_name = aws_appsync_domain_name.echostream_appsync.domain_name
}

module "appsync_domain" {
  domain_name = aws_appsync_domain_name.echostream_appsync.appsync_domain_name
  name        = lookup(local.regional_apis["domains"], var.region, "")
  zone_id     = data.aws_route53_zone.root_domain.zone_id

  source  = "QuiNovas/cloudfront-r53-alias-record/aws"
  version = "0.0.2"

  providers = {
    aws = aws.route-53
  }
}

##########################################################################################
##################################### Multi-Region #######################################
##########################################################################################

# This policy is attached to appsync service role to invoke the lambda datasource
data "aws_iam_policy_document" "multi_region_invoke_appsync_lambda_datasource" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      "arn:aws:lambda:*:${local.current_account_id}:function:${var.resource_prefix}-appsync-datasource",
    ]
    sid = "AllowInvokeOfLambdaDatasource"
  }
}

resource "aws_iam_policy" "multi_region_invoke_appsync_lambda_datasource" {
  name_prefix = "${var.resource_prefix}-multi-region-invoke-appsync-datasource"
  policy      = data.aws_iam_policy_document.multi_region_invoke_appsync_lambda_datasource.json
}

resource "aws_iam_role_policy_attachment" "multi_region_invoke_appsync_lambda_datasource" {
  role       = module.appsync_datasource_.role_name
  policy_arn = aws_iam_policy.multi_region_invoke_appsync_lambda_datasource.arn
}

# this policy is used for appsync api, for logs access
resource "aws_iam_role_policy_attachment" "multi_region_cloudwatch_appsync" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
  role       = module.appsync_datasource_.role_name
}
################################################################################################
# This policy is used to give permissions to multi region lambda env kms keys and dead letters
# and is attached to the appsync datasource lambda role, which is common to all multi region lambdas
data "aws_iam_policy_document" "multi_region_appsync_datasource" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:${local.current_account_id}:log-group:/aws/lambda/${var.resource_prefix}-appsync-datasource*",
    ]
    sid = "AllowLogWriting"
  }
  statement {
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
    ]
    resources = [
      aws_kms_key.lambda_environment_variables.arn,
      module.lambda_underpin_us_east_2.kms_key_arn,
      module.lambda_underpin_us_west_1.kms_key_arn,
      module.lambda_underpin_us_west_2.kms_key_arn,
    ]
    sid = "AllowEcryptDecryptEnvVars"
  }
  statement {
    actions = [
      "sns:Publish",
      "sqs:SendMessage",
    ]
    resources = [
      aws_sns_topic.lambda_dead_letter.arn,
      module.lambda_underpin_us_east_2.dead_letter_arn,
      module.lambda_underpin_us_west_1.dead_letter_arn,
      module.lambda_underpin_us_west_2.dead_letter_arn
    ]
    sid = "AllowDeadLetterWriting"
  }
}

resource "aws_iam_role_policy" "multi_region_appsync_datasource" {
  name   = "basic-access-all-regions"
  policy = data.aws_iam_policy_document.multi_region_appsync_datasource.json
  role   = "${var.resource_prefix}-appsync-datasource"
}

module "appsync_datasource_" {
  api_id                   = aws_appsync_graphql_api.echostream.id
  description              = "Main Lambda datasource for the echo-stream API "
  invoke_lambda_policy_arn = module.appsync_datasource.invoke_policy_arn
  lambda_function_arn      = module.appsync_datasource.arn
  name                     = replace("${var.resource_prefix}_appsync_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.4"
}

module "appsync_resolvers_us_east_1" {
  depends_on = [
    module.appsync_datasource_
  ]
  api_id          = aws_appsync_graphql_api.echostream.id
  datasource_name = module.appsync_datasource_.name
  source          = "./modules/appsync-resolvers"
}

################################################################################################

#######################
## Appsync us-east-2 ##
#######################
module "appsync_us_east_2" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "us-east-2") == true ? 1 : 0

  api_acm_arn                        = lookup(local.regional_apis["acm_arns"], "us-east-2", "")
  api_domain_name                    = lookup(local.regional_apis["domains"], "us-east-2", "")
  appsync_datasource_lambda_role_arn = module.appsync_datasource.role_arn
  appsync_service_role_arn           = module.appsync_datasource_.role_arn
  artifacts_bucket                   = "${local.artifacts_bucket_prefix}-us-east-2"
  dead_letter_arn                    = module.lambda_underpin_us_east_2.dead_letter_arn
  environment_variables              = local.common_lambda_environment_variables
  function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  kms_key_arn                        = module.lambda_underpin_us_east_2.kms_key_arn
  name                               = var.resource_prefix
  schema                             = data.aws_s3_object.graphql_schema.body
  tags                               = local.tags
  userpool_id                        = module.app_cognito_pool_us_east_2.0.userpool_id

  source = "./modules/appsync-api"

  providers = {
    aws = aws.ohio
  }
}

module "appsync_domain_us_east_2" {
  domain_name = module.appsync_us_east_2.0.appsync_domain_name
  name        = lookup(local.regional_apis["domains"], "us-east-2", "")
  zone_id     = data.aws_route53_zone.root_domain.zone_id

  source  = "QuiNovas/cloudfront-r53-alias-record/aws"
  version = "0.0.2"

  providers = {
    aws = aws.route-53
  }
}


module "appsync_resolvers_us_east_2" {
  depends_on = [
    module.appsync_us_east_2
  ]
  count = contains(local.regions, "us-east-2") == true ? 1 : 0

  api_id          = module.appsync_us_east_2.0.api_id
  datasource_name = module.appsync_us_east_2.0.datasource_name

  source = "./modules/appsync-resolvers"

  providers = {
    aws = aws.ohio
  }
}


#######################
## Appsync us-west-1 ##
#######################
module "appsync_us_west_1" {
  depends_on = [aws_acm_certificate_validation.regional_api]
  count      = contains(local.regions, "us-west-1") == true ? 1 : 0

  api_acm_arn                        = lookup(local.regional_apis["acm_arns"], "us-west-1", "")
  api_domain_name                    = lookup(local.regional_apis["domains"], "us-west-1", "")
  appsync_datasource_lambda_role_arn = module.appsync_datasource.role_arn
  appsync_service_role_arn           = module.appsync_datasource_.role_arn
  artifacts_bucket                   = "${local.artifacts_bucket_prefix}-us-west-1"
  dead_letter_arn                    = module.lambda_underpin_us_west_1.dead_letter_arn
  environment_variables              = local.common_lambda_environment_variables
  function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  kms_key_arn                        = module.lambda_underpin_us_west_1.kms_key_arn
  name                               = var.resource_prefix
  schema                             = data.aws_s3_object.graphql_schema.body
  tags                               = local.tags
  userpool_id                        = module.app_cognito_pool_us_west_1.0.userpool_id

  source = "./modules/appsync-api"

  providers = {
    aws = aws.north-california
  }
}

module "appsync_domain_us_west_1" {
  domain_name = module.appsync_us_west_1.0.appsync_domain_name
  name        = lookup(local.regional_apis["domains"], "us-west-1", "")
  zone_id     = data.aws_route53_zone.root_domain.zone_id

  source  = "QuiNovas/cloudfront-r53-alias-record/aws"
  version = "0.0.2"

  providers = {
    aws = aws.route-53
  }
}

module "appsync_resolvers_us_west_1" {
  depends_on = [
    module.appsync_us_west_1
  ]
  count = contains(local.regions, "us-west-1") == true ? 1 : 0

  api_id          = module.appsync_us_west_1.0.api_id
  datasource_name = module.appsync_us_west_1.0.datasource_name

  source = "./modules/appsync-resolvers"

  providers = {
    aws = aws.north-california
  }
}

#######################
## Appsync us-west-2 ##
#######################
module "appsync_us_west_2" {
  depends_on = [aws_acm_certificate_validation.regional_api]

  count = contains(local.regions, "us-west-2") == true ? 1 : 0

  api_acm_arn                        = lookup(local.regional_apis["acm_arns"], "us-west-2", "")
  api_domain_name                    = lookup(local.regional_apis["domains"], "us-west-2", "")
  appsync_datasource_lambda_role_arn = module.appsync_datasource.role_arn
  appsync_service_role_arn           = module.appsync_datasource_.role_arn
  artifacts_bucket                   = "${local.artifacts_bucket_prefix}-us-west-2"
  dead_letter_arn                    = module.lambda_underpin_us_west_2.dead_letter_arn
  environment_variables              = local.common_lambda_environment_variables
  function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  kms_key_arn                        = module.lambda_underpin_us_west_2.kms_key_arn
  name                               = var.resource_prefix
  schema                             = data.aws_s3_object.graphql_schema.body
  tags                               = local.tags
  userpool_id                        = module.app_cognito_pool_us_west_2.0.userpool_id

  source = "./modules/appsync-api"

  providers = {
    aws = aws.oregon
  }
}

module "appsync_domain_us_west_2" {
  domain_name = module.appsync_us_west_2.0.appsync_domain_name
  name        = lookup(local.regional_apis["domains"], "us-west-2", "")
  zone_id     = data.aws_route53_zone.root_domain.zone_id

  source  = "QuiNovas/cloudfront-r53-alias-record/aws"
  version = "0.0.2"

  providers = {
    aws = aws.route-53
  }
}

module "appsync_resolvers_us_west_2" {
  depends_on = [
    module.appsync_us_west_2
  ]
  count = contains(local.regions, "us-west-2") == true ? 1 : 0

  api_id          = module.appsync_us_west_2.0.api_id
  datasource_name = module.appsync_us_west_2.0.datasource_name

  source = "./modules/appsync-resolvers"

  providers = {
    aws = aws.oregon
  }
}