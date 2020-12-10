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

## AP-SOUTHEAST-1 

resource "aws_kms_key" "kms_ap_southeast_1" {
  count               = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.ap-southeast-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_ap_southeast_1" {
  count         = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_ap_southeast_1.0.key_id
  provider      = aws.ap-southeast-1
}

## AP-SOUTHEAST-2

resource "aws_kms_key" "kms_ap_southeast_2" {
  count               = contains(local.regions, "ap-southeast-2") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.ap-southeast-2
  tags                = local.tags
}

resource "aws_kms_alias" "kms_ap_southeast_2" {
  count         = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_ap_southeast_2.0.key_id
  provider      = aws.ap-southeast-2
}

## AP-NORTHEAST-1

resource "aws_kms_key" "kms_ap_northeast_1" {
  count               = contains(local.regions, "ap-northeast-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.ap-northeast-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_ap_northeast_1" {
  count         = contains(local.regions, "ap-northeast-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_ap_northeast_1.0.key_id
  provider      = aws.ap-northeast-1
}

## CA-CENTRAL-1

resource "aws_kms_key" "kms_ca_central_1" {
  count               = contains(local.regions, "ca-central-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.ca-central-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_ca_central_1" {
  count         = contains(local.regions, "ca-central-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_ca_central_1.0.key_id
  provider      = aws.ca-central-1
}


## EU-CENTRAL-1

resource "aws_kms_key" "kms_eu_central_1" {
  count               = contains(local.regions, "eu-central-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.eu-central-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_eu_central_1" {
  count         = contains(local.regions, "eu-central-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_eu_central_1.0.key_id
  provider      = aws.eu-central-1
}


## EU-WEST-1

resource "aws_kms_key" "kms_eu_west_1" {
  count               = contains(local.regions, "eu-west-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.eu-west-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_eu_west_1" {
  count         = contains(local.regions, "eu-west-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_eu_west_1.0.key_id
  provider      = aws.eu-west-1
}

## EU-WEST-2

resource "aws_kms_key" "kms_eu_west_2" {
  count               = contains(local.regions, "eu-west-2") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.eu-west-2
  tags                = local.tags
}

resource "aws_kms_alias" "kms_eu_west_2" {
  count         = contains(local.regions, "eu-west-2") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_eu_west_1.0.key_id
  provider      = aws.eu-west-2
}

## EU-SOUTH-1

resource "aws_kms_key" "kms_eu_south_1" {
  count               = contains(local.regions, "eu-south-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.eu-south-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_eu_south_1" {
  count         = contains(local.regions, "eu-south-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_eu_south_1.0.key_id
  provider      = aws.eu-south-1
}


## EU-WEST-3

resource "aws_kms_key" "kms_eu_west_3" {
  count               = contains(local.regions, "eu-west-3") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.eu-west-3
  tags                = local.tags
}

resource "aws_kms_alias" "kms_eu_west_3" {
  count         = contains(local.regions, "eu-west-3") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_eu_south_1.0.key_id
  provider      = aws.eu-west-3
}


## EU-NORTH-1

resource "aws_kms_key" "kms_eu_north_1" {
  count               = contains(local.regions, "eu-north-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.eu-north-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_eu_north_1" {
  count         = contains(local.regions, "eu-north-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_eu_north_1.0.key_id
  provider      = aws.eu-north-1
}


## ME-SOUTH-1

resource "aws_kms_key" "kms_me_south_1" {
  count               = contains(local.regions, "me-south-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.me-south-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_me_south_1" {
  count         = contains(local.regions, "me-south-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_me_south_1.0.key_id
  provider      = aws.me-south-1
}

## SA-EAST-1

resource "aws_kms_key" "kms_sa_east_1" {
  count               = contains(local.regions, "sa-east-1") == true ? 1 : 0
  description         = "Encryption key for ${var.environment_prefix}"
  enable_key_rotation = true
  provider            = aws.sa-east-1
  tags                = local.tags
}

resource "aws_kms_alias" "kms_sa_east_1" {
  count         = contains(local.regions, "sa-east-1") == true ? 1 : 0
  name          = "alias/${var.environment_prefix}"
  target_key_id = aws_kms_key.kms_sa_east_1.0.key_id
  provider      = aws.sa-east-1
}