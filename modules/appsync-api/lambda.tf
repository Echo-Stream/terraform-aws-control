resource "aws_lambda_function" "appsync_datasource" {
  description = "The main datasource for the echo-stream API"
  dead_letter_config {
    target_arn = var.dead_letter_arn
  }
  environment {
    variables = var.environment_variables
  }

  function_name = "${var.resource_prefix}-appsync-datasource"
  handler       = "function.handler"
  kms_key_arn   = var.kms_key_arn
  layers        = var.function_layers
  memory_size   = 1769
  role          = var.appsync_datasource_lambda_role_arn
  runtime       = var.runtime
  s3_bucket     = data.aws_s3_object.function_package.bucket
  s3_key        = data.aws_s3_object.function_package.key
  timeout       = 30
  tags          = var.tags
}

resource "aws_cloudwatch_log_group" "appsync_datasource" {
  name              = "/aws/lambda/${var.resource_prefix}-appsync-datasource"
  retention_in_days = 7
  tags              = var.tags
}
