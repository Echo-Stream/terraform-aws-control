data "aws_s3_object" "function_package" {
  bucket = var.artifacts_bucket
  key    = var.function_s3_object_key
}

resource "aws_lambda_function" "app_cognito_pre_authentication" {
  description = "Function that gets triggered when app cognito user to be authenticated"
  dead_letter_config {
    target_arn = var.dead_letter_arn
  }
  environment {
    variables = var.environment_variables
  }

  function_name = "${var.name}-app-cognito-pre-authentication"
  handler       = "function.handler"
  kms_key_arn   = var.kms_key_arn
  lifecycle {
    ignore_changes = [
      last_modified,
      qualified_arn,
      s3_object_version,
      version,
    ]
  }

  memory_size       = 1536
  role              = var.app_cognito_pre_authentication_lambda_role_arn
  runtime           = var.runtime
  s3_bucket         = data.aws_s3_object.function_package.bucket
  s3_key            = data.aws_s3_object.function_package.key
  s3_object_version = data.aws_s3_object.function_package.version_id
  timeout           = 30
  tags              = var.tags
}

resource "aws_lambda_permission" "app_cognito_pre_authentication" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app_cognito_pre_authentication.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.echostream_app.arn
}