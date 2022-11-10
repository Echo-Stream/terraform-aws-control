## Environment KMS Keys ##
## Control
resource "aws_kms_key" "kms_control" {
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_kms_alias" "kms_control" {
  name          = "alias/${var.resource_prefix}"
  target_key_id = aws_kms_key.kms_control.key_id
}

## US-EAST-1
resource "aws_kms_key" "kms_us_east_1" {
  count               = contains(local.non_control_regions, "us-east-1") == true ? 1 : 0
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  provider            = aws.us-east-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_east_1" {
  count         = contains(local.non_control_regions, "us-east-1") == true ? 1 : 0
  name          = "alias/${var.resource_prefix}"
  target_key_id = one(aws_kms_key.kms_us_east_1[*].key_id)
  provider      = aws.us-east-1
}

## US-EAST-2
resource "aws_kms_key" "kms_us_east_2" {
  count               = contains(local.non_control_regions, "us-east-2") == true ? 1 : 0
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  provider            = aws.us-east-2
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_east_2" {
  count         = contains(local.non_control_regions, "us-east-2") == true ? 1 : 0
  name          = "alias/${var.resource_prefix}"
  target_key_id = one(aws_kms_key.kms_us_east_2[*].key_id)
  provider      = aws.us-east-2
}


## US-WEST-1
resource "aws_kms_key" "kms_us_west_1" {
  count               = contains(local.non_control_regions, "us-west-1") == true ? 1 : 0
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  provider            = aws.us-west-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_west_1" {
  count         = contains(local.non_control_regions, "us-west-1") == true ? 1 : 0
  name          = "alias/${var.resource_prefix}"
  target_key_id = one(aws_kms_key.kms_us_west_1[*].key_id)
  provider      = aws.us-west-1
}

## US-WEST-2
resource "aws_kms_key" "kms_us_west_2" {
  count               = contains(local.non_control_regions, "us-west-2") == true ? 1 : 0
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  provider            = aws.us-west-2
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_west_2" {
  count         = contains(local.non_control_regions, "us-west-2") == true ? 1 : 0
  name          = "alias/${var.resource_prefix}"
  target_key_id = one(aws_kms_key.kms_us_west_2[*].key_id)
  provider      = aws.us-west-2
}
