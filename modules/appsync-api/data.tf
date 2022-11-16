data "aws_s3_object" "function_package" {
  bucket = var.artifacts_bucket
  key    = var.function_s3_object_key
}
