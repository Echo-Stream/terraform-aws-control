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
      user_pool_id = module.app_cognito_pool.userpool_id
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
  domain_name     = lookup(local.regional_apis["domains"], data.aws_region.current.name, "")
  certificate_arn = lookup(local.regional_apis["acm_arns"], data.aws_region.current.name, "")
}

resource "aws_appsync_domain_name_api_association" "echostream_appsync" {
  api_id      = aws_appsync_graphql_api.echostream.id
  domain_name = aws_appsync_domain_name.echostream_appsync.domain_name
}

module "appsync_domain" {
  domain_name = aws_appsync_domain_name.echostream_appsync.appsync_domain_name
  name        = lookup(local.regional_apis["domains"], data.aws_region.current.name, "")
  zone_id     = data.aws_route53_zone.root_domain.zone_id

  source  = "QuiNovas/cloudfront-r53-alias-record/aws"
  version = "0.0.2"

  providers = {
    aws = aws.route-53
  }
}

module "app_cognito_pool" {
  app_cognito_pre_authentication_lambda_role_arn = aws_iam_role.app_cognito_pre_authentication_function.arn
  artifacts_bucket                               = "${local.artifacts_bucket_prefix}-${data.aws_region.current.name}"
  dead_letter_arn                                = aws_sns_topic.lambda_dead_letter.arn
  environment_variables                          = local.app_api_cognito_pre_authentication_environment_variables
  function_s3_object_key                         = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  kms_key_arn                                    = aws_kms_key.lambda_environment_variables.arn
  name                                           = var.resource_prefix
  runtime                                        = local.lambda_runtime
  tags                                           = local.tags

  source = "./modules/app-user-pool"
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
      "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:${var.resource_prefix}-appsync-datasource",
    ]
    sid = "AllowInvokeOfLambdaDatasource"
  }
}

resource "aws_iam_policy" "multi_region_invoke_appsync_lambda_datasource" {
  name_prefix = "${var.resource_prefix}-multi-region-invoke-appsync-datasource"
  policy      = data.aws_iam_policy_document.multi_region_invoke_appsync_lambda_datasource.json
}

resource "aws_iam_role_policy_attachment" "multi_region_invoke_appsync_lambda_datasource" {
  role       = module.appsync_datasource.role_name
  policy_arn = aws_iam_policy.multi_region_invoke_appsync_lambda_datasource.arn
}

# this policy is used for appsync api, for logs access
resource "aws_iam_role_policy_attachment" "multi_region_cloudwatch_appsync" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
  role       = module.appsync_datasource.role_name
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
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.resource_prefix}-appsync-datasource*",
    ]
    sid = "AllowLogWriting"
  }
  statement {
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
    ]
    resources = concat(
      local.region_kms_key_arns,
      [aws_kms_key.lambda_environment_variables.arn]
    )
    sid = "AllowEcryptDecryptEnvVars"
  }
  statement {
    actions = [
      "sns:Publish",
      "sqs:SendMessage",
    ]
    resources = concat(
      local.region_dead_letter_arns,
      [aws_sns_topic.lambda_dead_letter.arn]
    )
    sid = "AllowDeadLetterWriting"
  }
}

resource "aws_iam_role_policy" "multi_region_appsync_datasource" {
  name   = "basic-access-all-regions"
  policy = data.aws_iam_policy_document.multi_region_appsync_datasource.json
  role   = "${var.resource_prefix}-appsync-datasource"
}

module "appsync_datasource" {
  api_id                   = aws_appsync_graphql_api.echostream.id
  description              = "Main Lambda datasource for the echo-stream API "
  invoke_lambda_policy_arn = module.appsync_datasource_lambda.invoke_policy_arn
  lambda_function_arn      = module.appsync_datasource_lambda.arn
  name                     = replace("${var.resource_prefix}_appsync_datasource", "-", "_")
  source                   = "QuiNovas/appsync-lambda-datasource/aws"
  version                  = "3.0.4"
}

module "appsync_resolvers" {
  depends_on = [
    module.appsync_datasource
  ]
  api_id          = aws_appsync_graphql_api.echostream.id
  datasource_name = module.appsync_datasource.name
  source          = "./modules/appsync-resolvers"
}
