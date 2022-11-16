data "aws_s3_object" "echocore_json" {
  bucket = local.artifacts_bucket
  key    = local.lambda_layer_keys["echocore"]
}

locals {
  echocore_layer_version_arns = jsondecode(data.aws_s3_object.echocore_json.body)
}