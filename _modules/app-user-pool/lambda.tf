module "app_cognito_pre_authentication" {
  description = "Function that gets triggered when cognito user to be authenticated"

  environment_variables = {
    CONTROL_REGION = var.control_region
    DYNAMODB_TABLE = var.graph_table_name
    ENVIRONMENT    = var.environment
    TENANT_REGIONS = var.tenant_regions
  }

  dead_letter_arn = var.dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = var.kms_key_arn
  memory_size     = 1536
  name            = "${var.name}-${var.tenant_region}-app-cognito-pre-authentication"

  policy_arns = [
    var.app_cognito_pre_authentication_iam_policy_arn,
    var.graph_ddb_read_iam_policy_arn
  ]

  runtime       = "python3.9"
  s3_bucket     = var.artifacts_bucket
  s3_object_key = var.function_s3_object_key
  source        = "QuiNovas/lambda/aws"
  tags          = var.tags
  timeout       = 30
  version       = "4.0.0"
}

resource "aws_lambda_permission" "app_cognito_pre_authentication" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.app_cognito_pre_authentication.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_app.arn
}