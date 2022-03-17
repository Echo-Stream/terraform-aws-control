################################################################################################
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

################################################################################################

#######################
## Appsync us-east-2 ##
#######################
module "appsync_us_east_2" {
  count = contains(local.regions, "us-east-2") == true ? 1 : 0

  api_acm_arn                        = lookup(var.regional_apis["acm_arns"], "us-east-2", "")
  api_domain_name                    = lookup(var.regional_apis["domains"], "us-east-2", "")
  appsync_datasource_lambda_role_arn = module.appsync_datasource.role_arn
  appsync_service_role_arn           = module.appsync_datasource_.role_arn
  artifacts_bucket                   = "${local.artifacts_bucket_prefix}-us-east-2"
  dead_letter_arn                    = module.lambda_underpin_us_east_2.dead_letter_arn
  environment_variables              = local.appsync_datasource_lambda_environment_variables
  function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  kms_key_arn                        = module.lambda_underpin_us_east_2.kms_key_arn
  name                               = var.resource_prefix
  schema                             = data.aws_s3_object.graphql_schema.body
  tags                               = local.tags
  userpool_id                        = module.app_cognito_pool_us_east_2.0.userpool_id

  source = "./_modules/appsync"

  providers = {
    aws = aws.ohio
  }
}