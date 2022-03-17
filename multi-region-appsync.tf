data "aws_iam_policy_document" "invoke_appsync_datasource" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      "arn:aws:lambda:*:${local.current_account_id}:function:${var.resource_prefix}-appsync-datasource",
    ]
    sid = "AllowInvoke"
  }
}

resource "aws_iam_policy" "invoke_appsync_datasource" {
  name_prefix = "${var.resource_prefix}-invoke-appsync-datasource"
  policy      = data.aws_iam_policy_document.invoke_appsync_datasource.json
}

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
  name   = "basic-access-2"
  policy = data.aws_iam_policy_document.multi_region_appsync_datasource.json
  role   = aws_iam_role.app_cognito_pre_authentication_function.id
}

#######################
## Appsync us-east-2 ##
#######################
module "appsync_us_east_2" {
  count = contains(local.regions, "us-east-2") == true ? 1 : 0

  appsync_datasource_lambda_role_arn = module.appsync_datasource.role_arn
  schema                             = data.aws_s3_object.graphql_schema.body
  appsync_role_arn                   = aws_iam_role.echostream_appsync.arn
  artifacts_bucket                   = "${local.artifacts_bucket_prefix}-us-east-2"
  dead_letter_arn                    = module.lambda_underpin_us_east_2.dead_letter_arn
  function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  kms_key_arn                        = module.lambda_underpin_us_east_2.kms_key_arn
  name                               = var.resource_prefix
  tags                               = local.tags
  userpool_id                        = module.app_cognito_pool_us_east_2.0.userpool_id
  invoke_policy_arn                  = aws_iam_policy.invoke_appsync_datasource.arn

  source = "./_modules/appsync"

  providers = {
    aws = aws.ohio
  }
}