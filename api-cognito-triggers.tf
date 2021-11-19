####################################
##  ui-cognito-post-confirmation  ##
####################################
data "aws_iam_policy_document" "ui_cognito_post_confirmation" {
  statement {
    actions = [
      "dynamodb:UpdateItem",
      "dynamodb:Query",
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/*",
    ]

    sid = "TableAccess"
  }
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
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-ui-cognito-post-confirmation"
  policy      = data.aws_iam_policy_document.ui_cognito_post_confirmation.json
}

module "ui_cognito_post_confirmation" {
  description = "Set attributes on UI user and validate invitation token post signup "

  environment_variables = {
    CONTROL_REGION = local.current_region
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.resource_prefix
    TENANT_REGIONS = jsonencode(local.tenant_regions)
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.resource_prefix}-ui-cognito-post-confirmation"

  policy_arns = [
    aws_iam_policy.ui_cognito_post_confirmation.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_post_confirmation"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.17"
}

resource "aws_lambda_permission" "ui_cognito_post_confirmation" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_post_confirmation.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_ui.arn
}

resource "aws_cloudwatch_log_subscription_filter" "ui_cognito_post_confirmation" {
  name            = "${var.resource_prefix}-ui-cognito-post-confirmation"
  log_group_name  = module.ui_cognito_post_confirmation.log_group_name
  filter_pattern  = "ERROR -SignupError -InternalError"
  destination_arn = module.control_alert_handler.arn
}

#####################################
##  ui-cognito-pre-authentication  ##
#####################################
data "aws_iam_policy_document" "ui_cognito_pre_authentication" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem"

    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
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
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-ui-cognito-pre-authentication"
  policy      = data.aws_iam_policy_document.ui_cognito_pre_authentication.json
}

module "ui_cognito_pre_authentication" {
  description = "Check status and tenant membership pre authentication for UI users"

  environment_variables = {
    CONTROL_REGION = local.current_region
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.resource_prefix
    TENANT_REGIONS = jsonencode(local.tenant_regions)
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.resource_prefix}-ui-cognito-pre-authentication"

  policy_arns = [
    aws_iam_policy.ui_cognito_pre_authentication.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_pre_authentication"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.17"
}

resource "aws_lambda_permission" "ui_cognito_pre_authentication" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_pre_authentication.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_ui.arn
}

resource "aws_cloudwatch_log_subscription_filter" "ui_cognito_pre_authentication" {
  name            = "${var.resource_prefix}-ui-cognito-pre-authentication"
  log_group_name  = module.ui_cognito_pre_authentication.log_group_name
  filter_pattern  = "ERROR -UserNotAuthorizedError"
  destination_arn = module.control_alert_handler.arn
}

#############################
##  ui-cognito-pre-signup  ##
#############################
data "aws_iam_policy_document" "ui_cognito_pre_signup" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
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
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-ui-cognito-pre-signup"
  policy      = data.aws_iam_policy_document.ui_cognito_pre_signup.json
}

module "ui_cognito_pre_signup" {
  description = "Validate invitation for new UI user "

  environment_variables = {
    CONTROL_REGION = local.current_region
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.resource_prefix
    TENANT_REGIONS = jsonencode(local.tenant_regions)
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.resource_prefix}-ui-cognito-pre-signup"

  policy_arns = [
    aws_iam_policy.ui_cognito_pre_signup.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_pre_signup"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.17"
}

resource "aws_lambda_permission" "ui_cognito_pre_signup" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_pre_signup.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_ui.arn
}

resource "aws_cloudwatch_log_subscription_filter" "ui_cognito_pre_signup" {
  name            = "${var.resource_prefix}-ui-cognito-pre-signup"
  log_group_name  = module.ui_cognito_pre_signup.log_group_name
  filter_pattern  = "ERROR -SignupError -InternalError"
  destination_arn = module.control_alert_handler.arn
}


##########################################
##  app-api-cognito-pre-authentication  ##
##########################################
data "aws_iam_policy_document" "app_api_cognito_pre_authentication" {
  statement {
    actions = [
      "dynamodb:Query",
    ]

    resources = [
      "${module.graph_table.arn}/*",
    ]

    sid = "TableAccess"
  }

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

resource "aws_iam_policy" "app_api_cognito_pre_authentication" {
  description = "IAM permissions required for app-api-cognito-pre-authentication lambda"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-app-api-cognito-pre-authentication"
  policy      = data.aws_iam_policy_document.app_api_cognito_pre_authentication.json
}

module "app_api_cognito_pre_authentication" {
  description = "Function that gets triggered when cognito user to be authenticated"
  environment_variables = {
    CONTROL_REGION = local.current_region
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.resource_prefix
    TENANT_REGIONS = jsonencode(local.tenant_regions)
  }
  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.resource_prefix}-app-api-cognito-pre-authentication"

  policy_arns = [
    aws_iam_policy.app_api_cognito_pre_authentication.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["app_api_cognito_pre_authentication"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.17"
}

resource "aws_lambda_permission" "app_api_cognito_pre_authentication" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.app_api_cognito_pre_authentication.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_api.arn
}

resource "aws_cloudwatch_log_subscription_filter" "app_api_cognito_pre_authentication" {
  name            = "${var.resource_prefix}-app-api-cognito-pre-authentication"
  log_group_name  = module.app_api_cognito_pre_authentication.log_group_name
  filter_pattern  = "ERROR -AppNotAuthorizedError"
  destination_arn = module.control_alert_handler.arn
}

# ########################################
# ##  app-cognito-pre-token-generation  ##
# ########################################
# data "aws_iam_policy_document" "app_cognito_pre_token_generation" {
#   statement {
#     actions = [
#       "dynamodb:DescribeTable",
#       "dynamodb:GetItem",
#     ]

#     resources = [
#       module.graph_table.arn,
#     ]

#     sid = "TableAccess"
#   }

#   statement {
#     actions = [
#       "cloudwatch:PutMetricData",
#     ]

#     resources = [
#       "*",
#     ]

#     sid = "CWPutMetrics"
#   }
# }

# resource "aws_iam_policy" "app_cognito_pre_token_generation" {
#   description = "IAM permissions required for app-cognito-pre-token-generation lambda"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-app-cognito-pre-token-generation"
#   policy      = data.aws_iam_policy_document.app_cognito_pre_token_generation.json
# }

# module "app_cognito_pre_token_generation" {
#   description = "Customizes the claims in the identity token"
#   environment_variables = {
#     DYNAMODB_TABLE = module.graph_table.name
#     ENVIRONMENT    = var.resource_prefix
#     CONTROL_REGION = local.current_region
#   }
#   dead_letter_arn = local.lambda_dead_letter_arn
#   handler         = "function.handler"
#   kms_key_arn     = local.lambda_env_vars_kms_key_arn
#   memory_size     = 1536
#   name            = "${var.resource_prefix}-app-cognito-pre-token-generation"

#   policy_arns = [
#     aws_iam_policy.app_cognito_pre_token_generation.arn,
#     aws_iam_policy.additional_ddb_policy.arn
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["app_cognito_pre_token_generation"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 30
#   version       = "3.0.17"
# }

# resource "aws_lambda_permission" "app_cognito_pre_token_generation" {
#   statement_id  = "AllowExecutionFromCognito"
#   action        = "lambda:InvokeFunction"
#   function_name = module.app_cognito_pre_token_generation.name
#   principal     = "cognito-idp.amazonaws.com"
#   source_arn    = aws_cognito_user_pool.echostream_apps.arn
# }

# resource "aws_cloudwatch_log_subscription_filter" "app_cognito_pre_token_generation" {
#   name            = "${var.resource_prefix}-app-cognito-pre-token-generation"
#   log_group_name  = module.app_cognito_pre_token_generation.log_group_name
#   filter_pattern  = "ERROR -AppNotAuthorizedError"
#   destination_arn = module.control_alert_handler.arn
# }