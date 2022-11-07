resource "aws_sns_topic" "lambda_dead_letter" {
  display_name = "${var.resource_prefix}-lambda-dead-letter"
  name         = "${var.resource_prefix}-lambda-dead-letter"
  tags         = var.tags
}

resource "aws_kms_key" "lambda_environment_variables" {
  description         = "Key for lambda environment variables ${var.resource_prefix}"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "lambda_environment_variables" {
  name          = "alias/${var.resource_prefix}-lambda-environment-variables"
  target_key_id = aws_kms_key.lambda_environment_variables.key_id
}

module "log_bucket" {
  name_prefix  = var.resource_prefix
  name_postfix = data.aws_region.current.name
  tags         = var.tags

  source  = "QuiNovas/log-bucket/aws"
  version = "4.0.0"
}

resource "aws_cloudwatch_log_group" "audit_firehose" {
  name              = var.audit_firehose_log_group
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_kms_key" "environment" {
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "environment" {
  name          = "alias/${var.resource_prefix}"
  target_key_id = aws_kms_key.environment.key_id
}

module "app_cognito_pool" {
  app_cognito_pre_authentication_lambda_role_arn = var.app_cognito_pre_authentication_lambda_role_arn
  artifacts_bucket                               = "${var.artifacts_bucket_prefix}-${data.aws_region.current.name}"
  dead_letter_arn                                = aws_sns_topic.lambda_dead_letter.arn
  environment_variables                          = var.app_cognito_pre_authentication_environment_variables
  function_s3_object_key                         = var.app_cognito_pre_authentication_function_s3_object_key
  kms_key_arn                                    = aws_kms_key.lambda_environment_variables.arn
  name                                           = var.resource_prefix
  runtime                                        = var.lambda_runtime
  tags                                           = var.tags

  source = "../app-user-pool"
}

resource "aws_appsync_graphql_api" "echostream" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  log_config {
    cloudwatch_logs_role_arn = var.appsync_service_role_arn
    field_log_level          = "ERROR"
  }

  user_pool_config {
    default_action = "ALLOW"
    user_pool_id   = module.app_cognito_pool.userpool_id
  }

  schema       = var.schema
  xray_enabled = false
  name         = "${var.resource_prefix}-api"

  tags = var.tags
}

resource "aws_appsync_datasource" "appsync_datasource" {
  api_id      = aws_appsync_graphql_api.echostream.id
  description = "Main Lambda datasource for the regional echo-stream API "

  lambda_config {
    function_arn = aws_lambda_function.appsync_datasource_lambda.arn
  }

  name             = replace("${var.resource_prefix}_appsync_datasource", "-", "_")
  service_role_arn = var.appsync_service_role_arn
  type             = "AWS_LAMBDA"
}

resource "aws_appsync_domain_name" "echostream_appsync" {
  certificate_arn = lookup(var.regional_api_acm_arns, data.aws_region.current.name, "")
  domain_name     = lookup(var.regional_domain_names, data.aws_region.current.name, "")
}

resource "aws_appsync_domain_name_api_association" "echostream_appsync" {
  api_id      = aws_appsync_graphql_api.echostream.id
  domain_name = aws_appsync_domain_name.echostream_appsync.domain_name
}

resource "aws_lambda_function" "appsync_datasource_function" {
  description = "Function that gets triggered when app cognito user to be authenticated"
  dead_letter_config {
    target_arn = aws_sns_topic.lambda_dead_letter.arn
  }
  environment {
    variables = var.common_lambda_environment_variables
  }

  function_name = "${var.resource_prefix}-appsync-datasource"
  handler       = "function.handler"
  kms_key_arn   = aws_kms_key.lambda_environment_variables.arn
  lifecycle {
    ignore_changes = [
      last_modified,
      qualified_arn,
      version,
    ]
  }

  memory_size = 1536
  role        = var.appsync_datasource_lambda_role_arn
  runtime     = var.runtime
  s3_bucket   = data.aws_s3_object.function_package.bucket
  s3_key      = data.aws_s3_object.function_package.key
  timeout     = 30
  tags        = var.tags
}

resource "aws_cloudwatch_log_group" "appsync_datasource" {
  name              = "/aws/lambda/${var.resource_prefix}-appsync-datasource"
  retention_in_days = 7
  tags              = var.tags
}

module "appsync_domain" {
  domain_name = aws_appsync_domain_name.echostream_appsync.appsync_domain_name
  name        = lookup(var.regional_domain_names, data.aws_region.current.name, "")
  zone_id     = var.zone_id

  source  = "QuiNovas/cloudfront-r53-alias-record/aws"
  version = "0.0.2"

  providers = {
    aws = aws.route-53
  }
}

module "appsync_resolvers" {
  api_id          = aws_appsync_graphql_api.echostream.id
  datasource_name = aws_appsync_datasource.appsync_datasource.name

  source = "../appsync-resolvers"
}
