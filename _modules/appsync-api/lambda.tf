data "aws_s3_object" "function_package" {
  bucket = var.artifacts_bucket
  key    = var.function_s3_object_key
}

resource "aws_lambda_function" "appsync_datasource" {
  description = "Function that gets triggered when app cognito user to be authenticated"
  dead_letter_config {
    target_arn = var.dead_letter_arn
  }
  environment {
    variables = var.environment_variables
  }

  function_name = "${var.name}-appsync-datasource"
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
  role              = var.appsync_datasource_lambda_role_arn
  runtime           = var.runtime
  s3_bucket         = data.aws_s3_object.function_package.bucket
  s3_key            = data.aws_s3_object.function_package.key
  s3_object_version = data.aws_s3_object.function_package.version_id
  timeout           = 30
  tags              = var.tags
}