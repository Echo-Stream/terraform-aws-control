###########################
##  appsync-datasource  ##
###########################
module "appsync_datasource" {
  description           = "The main datasource for the echo-stream API"
  dead_letter_arn       = local.lambda_dead_letter_arn
  environment_variables = local.common_lambda_environment_variables
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  layers                = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size           = 1769
  name                  = "${var.resource_prefix}-appsync-datasource"

  policy_arns = [
    data.aws_iam_policy.administrator_access.arn
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "4.0.2"
}
