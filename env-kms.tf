## Environment KMS Keys ##

## US-EAST-1
resource "aws_kms_key" "kms_us_east_1" {
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.us-east-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_east_1" {
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_us_east_1.key_id
  provider      = aws.us-east-1
}

## US-EAST-2
resource "aws_kms_key" "kms_us_east_2" {
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.us-east-2
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_east_2" {
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_us_east_2.key_id
  provider      = aws.us-east-2
}


## US-WEST-1
resource "aws_kms_key" "kms_us_west_1" {
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.us-west-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_west_1" {
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_us_west_1.key_id
  provider      = aws.us-west-1
}


## US-WEST-2
resource "aws_kms_key" "kms_us_west_2" {
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.us-west-2
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_west_2" {
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_us_west_2.key_id
  provider      = aws.us-west-2
}