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

#######################
## Appsync us-east-2 ##
#######################
module "appsync_us_east_2" {
  count = contains(local.regions, "us-east-2") == true ? 1 : 0

  appsync_datasource_lambda_role_arn = module.appsync_datasource.role_arn
  artifacts_bucket                   = "${local.artifacts_bucket_prefix}-us-east-2"
  dead_letter_arn                    = module.lambda_underpin_us_east_2.dead_letter_arn
  function_s3_object_key             = local.lambda_functions_keys["appsync_datasource"]
  kms_key_arn                        = module.lambda_underpin_us_east_2.kms_key_arn
  name                               = var.resource_prefix
  tags                               = local.tags
  user_pool_id                       = module.app_cognito_pool_us_east_2.userpool_id
  invoke_policy_arn                  = aws_iam_policy.invoke_appsync_datasource.arn

  source = "./_modules/appsync"

  providers = {
    aws = aws.ohio
  }
}