## Environment KMS Keys ##

## US-EAST-1
resource "aws_kms_key" "kms_us_east_1" {
  count               = contains(local.regions, "us-east-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.us-east-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_east_1" {
  count         = contains(local.regions, "us-east-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_us_east_1.0.key_id
  provider      = aws.us-east-1
}

## US-EAST-2
resource "aws_kms_key" "kms_us_east_2" {
  count               = contains(local.regions, "us-east-2") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.us-east-2
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_east_2" {
  count         = contains(local.regions, "us-east-2") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_us_east_2.0.key_id
  provider      = aws.us-east-2
}


## US-WEST-1
resource "aws_kms_key" "kms_us_west_1" {
  count               = contains(local.regions, "us-west-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.us-west-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_west_1" {
  count         = contains(local.regions, "us-west-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_us_west_1.0.key_id
  provider      = aws.us-west-1
}

## US-WEST-2
resource "aws_kms_key" "kms_us_west_2" {
  count               = contains(local.regions, "us-west-2") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.us-west-2
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_west_2" {
  count         = contains(local.regions, "us-west-2") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_us_west_2.0.key_id
  provider      = aws.us-west-2
}

## AF-SOUTH-1
resource "aws_kms_key" "kms_af_south_1" {
  count               = contains(local.regions, "af-south-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.af-south-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_af_south_1" {
  count         = contains(local.regions, "af-south-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_af_south_1.0.key_id
  provider      = aws.af-south-1
}

## AP-EAST-1
resource "aws_kms_key" "kms_ap_east_1" {
  count               = contains(local.regions, "ap-east-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.ap-east-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_ap_east_1" {
  count         = contains(local.regions, "ap-east-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_ap_east_1.0.key_id
  provider      = aws.ap-east-1
}

## AP-SOUTH-1
resource "aws_kms_key" "kms_ap_south_1" {
  count               = contains(local.regions, "ap-south-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.ap-south-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_ap_south_1" {
  count         = contains(local.regions, "ap-south-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_ap_south_1.0.key_id
  provider      = aws.ap-south-1
}

## AP-NORTHEAST-2
resource "aws_kms_key" "kms_ap_northeast_2" {
  count               = contains(local.regions, "ap-northeast-2") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.ap-northeast-2
  tags                = local.tags
}

resource "aws_kms_alias" "kms_ap_northeast_2" {
  count         = contains(local.regions, "ap-northeast-2") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_ap_northeast_2.0.key_id
  provider      = aws.ap-northeast-2
}