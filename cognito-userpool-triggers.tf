locals {
  app_api_cognito_pre_authentication_environment_variables = {
    CONTROL_REGION = data.aws_region.current.name
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.resource_prefix
    TENANT_REGIONS = jsonencode(local.tenant_regions)
  }
}

####################################
##  ui-cognito-post-confirmation  ##
####################################
data "aws_iam_policy_document" "ui_cognito_post_confirmation" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]

    sid = "CWPutMetrics"
  }
}

resource "aws_iam_policy" "ui_cognito_post_confirmation" {
  description = "IAM permissions required for ui-cognito-post-confirmation lambda"

  name   = "${var.resource_prefix}-ui-cognito-post-confirmation"
  policy = data.aws_iam_policy_document.ui_cognito_post_confirmation.json
}

module "ui_cognito_post_confirmation" {
  description = "Set attributes on UI user and validate invitation token post signup "

  environment_variables = {
    CONTROL_REGION = data.aws_region.current.name
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.resource_prefix
    TENANT_REGIONS = jsonencode(local.tenant_regions)
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  layers          = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size     = 1536
  name            = "${var.resource_prefix}-ui-cognito-post-confirmation"

  policy_arns = [
    aws_iam_policy.ui_cognito_post_confirmation.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.graph_ddb_write.arn
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_post_confirmation"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "4.0.2"
}

resource "aws_lambda_permission" "ui_cognito_post_confirmation" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_post_confirmation.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_ui.arn
}

#####################################
##  ui-cognito-pre-authentication  ##
#####################################
data "aws_iam_policy_document" "ui_cognito_pre_authentication" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]

    sid = "CWPutMetrics"
  }
}

resource "aws_iam_policy" "ui_cognito_pre_authentication" {
  description = "IAM permissions required for ui-cognito-pre-authentication lambda"

  name   = "${var.resource_prefix}-ui-cognito-pre-authentication"
  policy = data.aws_iam_policy_document.ui_cognito_pre_authentication.json
}

module "ui_cognito_pre_authentication" {
  description = "Check status and tenant membership pre authentication for UI users"

  environment_variables = {
    CONTROL_REGION = data.aws_region.current.name
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.resource_prefix
    TENANT_REGIONS = jsonencode(local.tenant_regions)
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  layers          = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size     = 1536
  name            = "${var.resource_prefix}-ui-cognito-pre-authentication"

  policy_arns = [
    aws_iam_policy.ui_cognito_pre_authentication.arn,
    aws_iam_policy.graph_ddb_read.arn
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_pre_authentication"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "4.0.2"
}

resource "aws_lambda_permission" "ui_cognito_pre_authentication" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_pre_authentication.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_ui.arn
}

#############################
##  ui-cognito-pre-signup  ##
#############################
data "aws_iam_policy_document" "ui_cognito_pre_signup" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]

    sid = "CWPutMetrics"
  }
}

resource "aws_iam_policy" "ui_cognito_pre_signup" {
  description = "IAM permissions required for ui-cognito-pre-signup lambda"

  name   = "${var.resource_prefix}-ui-cognito-pre-signup"
  policy = data.aws_iam_policy_document.ui_cognito_pre_signup.json
}

module "ui_cognito_pre_signup" {
  description = "Validate invitation for new UI user "

  environment_variables = {
    AUTHORIZED_DOMAINS = jsonencode(var.authorized_domains)
    CHECK_DOMAINS      = var.check_domains
    CONTROL_REGION     = data.aws_region.current.name
    DYNAMODB_TABLE     = module.graph_table.name
    ENVIRONMENT        = var.resource_prefix
    TENANT_REGIONS     = jsonencode(local.tenant_regions)
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  layers          = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size     = 1536
  name            = "${var.resource_prefix}-ui-cognito-pre-signup"

  policy_arns = [
    aws_iam_policy.ui_cognito_pre_signup.arn,
    aws_iam_policy.graph_ddb_read.arn
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_pre_signup"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "4.0.2"
}

resource "aws_lambda_permission" "ui_cognito_pre_signup" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_pre_signup.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_ui.arn
}

######################################
##  api-cognito-pre-authentication  ##
######################################
data "aws_iam_policy_document" "api_cognito_pre_authentication" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]

    sid = "CWPutMetrics"
  }
}

resource "aws_iam_policy" "api_cognito_pre_authentication" {
  description = "IAM permissions required for api-cognito-pre-authentication lambda"

  name   = "${var.resource_prefix}-api-cognito-pre-authentication"
  policy = data.aws_iam_policy_document.api_cognito_pre_authentication.json
}

module "api_cognito_pre_authentication" {
  description           = "Function that gets triggered when api cognito user to be authenticated"
  environment_variables = local.app_api_cognito_pre_authentication_environment_variables
  dead_letter_arn       = local.lambda_dead_letter_arn
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  layers                = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size           = 1536
  name                  = "${var.resource_prefix}-api-cognito-pre-authentication"

  policy_arns = [
    aws_iam_policy.api_cognito_pre_authentication.arn,
    aws_iam_policy.graph_ddb_read.arn
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "4.0.2"
}

resource "aws_lambda_permission" "api_cognito_pre_authentication" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.api_cognito_pre_authentication.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_api.arn
}
