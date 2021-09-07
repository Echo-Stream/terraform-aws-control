# #######################################
# ##  api-cognito-pre-token-generation  ##
# #######################################
# data "aws_iam_policy_document" "api_cognito_pre_token_generation" {
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

#   statement {
#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:CreateLogGroup",
#     ]

#     resources = [
#       "*",
#     ]

#     sid = "AllowWritingErrorEvents"
#   }
# }

# resource "aws_iam_policy" "api_cognito_pre_token_generation" {
#   description = "IAM permissions required for api-cognito-pre-token-generation lambda"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-api-cognito-pre-token-generation"
#   policy      = data.aws_iam_policy_document.api_cognito_pre_token_generation.json
# }

# module "api_cognito_pre_token_generation" {
#   description = "Injects claims for API users"

#   environment_variables = {
#     DYNAMODB_TABLE = module.graph_table.name
#     ENVIRONMENT    = var.resource_prefix
#   }

#   dead_letter_arn = local.lambda_dead_letter_arn
#   handler         = "function.handler"
#   kms_key_arn     = local.lambda_env_vars_kms_key_arn
#   memory_size     = 1536
#   name            = "${var.resource_prefix}-api-cognito-pre-token-generation"

#   policy_arns = [
#     aws_iam_policy.api_cognito_pre_token_generation.arn,
#     aws_iam_policy.additional_ddb_policy.arn
#   ]

#   runtime       = "python3.8"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["api_cognito_pre_token_generation"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 30
#   version       = "3.0.14"
# }

# resource "aws_lambda_permission" "api_cognito_pre_token_generation" {
#   statement_id  = "AllowExecutionFromCognito"
#   action        = "lambda:InvokeFunction"
#   function_name = module.api_cognito_pre_token_generation.name
#   principal     = "cognito-idp.amazonaws.com"
#   source_arn    = aws_cognito_user_pool.echostream_api.arn
# }

# resource "aws_cloudwatch_log_subscription_filter" "api_cognito_pre_token_generation" {
#   name            = "${var.resource_prefix}-api-cognito-pre-token-generation"
#   log_group_name  = module.api_cognito_pre_token_generation.log_group_name
#   filter_pattern  = "ERROR -UserNotAuthorizedError"
#   destination_arn = module.control_alert_handler.arn
# }

# ######################################
# ##  api-cognito-pre-authentication  ##
# ######################################
# data "aws_iam_policy_document" "api_cognito_pre_authentication" {
#   statement {
#     actions = [
#       "dynamodb:Query",
#     ]

#     resources = [
#       "${module.graph_table.arn}/*",
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

#   statement {
#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:CreateLogGroup",
#     ]

#     resources = [
#       "*",
#     ]

#     sid = "AllowWritingErrorEvents"
#   }
# }

# resource "aws_iam_policy" "api_cognito_pre_authentication" {
#   description = "IAM permissions required for api-cognito-pre-authentication lambda"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-api-cognito-pre-authentication"
#   policy      = data.aws_iam_policy_document.api_cognito_pre_authentication.json
# }

# module "api_cognito_pre_authentication" {
#   description = "Function that gets triggered when cognito user to be authenticated"

#   environment_variables = {
#     DYNAMODB_TABLE = module.graph_table.name
#     ENVIRONMENT    = var.resource_prefix
#     INDEX_NAME     = "gsi0"
#   }

#   dead_letter_arn = local.lambda_dead_letter_arn
#   handler         = "function.handler"
#   kms_key_arn     = local.lambda_env_vars_kms_key_arn
#   memory_size     = 1536
#   name            = "${var.resource_prefix}-api-cognito-pre-authentication"

#   policy_arns = [
#     aws_iam_policy.api_cognito_pre_authentication.arn,
#     aws_iam_policy.additional_ddb_policy.arn
#   ]

#   runtime       = "python3.8"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["api_cognito_pre_authentication"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 30
#   version       = "3.0.14"
# }

# resource "aws_lambda_permission" "api_cognito_pre_authentication" {
#   statement_id  = "AllowExecutionFromCognito"
#   action        = "lambda:InvokeFunction"
#   function_name = module.api_cognito_pre_authentication.name
#   principal     = "cognito-idp.amazonaws.com"
#   source_arn    = aws_cognito_user_pool.echostream_api.arn
# }

# resource "aws_cloudwatch_log_subscription_filter" "api_cognito_pre_authentication" {
#   name            = "${var.resource_prefix}-api-cognito-pre-authentication"
#   log_group_name  = module.api_cognito_pre_authentication.log_group_name
#   filter_pattern  = "ERROR -UserNotAuthorizedError"
#   destination_arn = module.control_alert_handler.arn
# }
