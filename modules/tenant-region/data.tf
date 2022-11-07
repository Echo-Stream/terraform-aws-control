data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_s3_object" "function_package" {
  bucket = "${var.artifacts_bucket_prefix}-${data.aws_region.current.name}"
  key    = var.appsync_datasource_function_s3_object_key
}
