resource "aws_kms_key" "environment" {
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_kms_alias" "environment" {
  name          = "alias/${var.resource_prefix}"
  target_key_id = aws_kms_key.environment.key_id
}
