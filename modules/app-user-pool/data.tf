data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_s3_object" "function_package" {
  bucket = var.artifacts_bucket
  key    = var.function_s3_object_key
}
