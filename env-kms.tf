## Environment KMS Keys ##
## US-EAST-1
resource "aws_kms_key" "kms_us_east_1" {
  count               = contains(local.regions, "us-east-1") == true ? 1 : 0
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  provider            = aws.north-virginia
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_east_1" {
  count         = contains(local.regions, "us-east-1") == true ? 1 : 0
  name          = "alias/${var.resource_prefix}"
  target_key_id = aws_kms_key.kms_us_east_1.0.key_id
  provider      = aws.north-virginia
}

## US-EAST-2
resource "aws_kms_key" "kms_us_east_2" {
  count               = contains(local.regions, "us-east-2") == true ? 1 : 0
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  provider            = aws.ohio
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_east_2" {
  count         = contains(local.regions, "us-east-2") == true ? 1 : 0
  name          = "alias/${var.resource_prefix}"
  target_key_id = aws_kms_key.kms_us_east_2.0.key_id
  provider      = aws.ohio
}


## US-WEST-1
resource "aws_kms_key" "kms_us_west_1" {
  count               = contains(local.regions, "us-west-1") == true ? 1 : 0
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  provider            = aws.north-california
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_west_1" {
  count         = contains(local.regions, "us-west-1") == true ? 1 : 0
  name          = "alias/${var.resource_prefix}"
  target_key_id = aws_kms_key.kms_us_west_1.0.key_id
  provider      = aws.north-california
}

## US-WEST-2
resource "aws_kms_key" "kms_us_west_2" {
  count               = contains(local.regions, "us-west-2") == true ? 1 : 0
  description         = "Encryption key for ${var.resource_prefix}"
  enable_key_rotation = true
  provider            = aws.oregon
  tags                = local.tags
}

resource "aws_kms_alias" "kms_us_west_2" {
  count         = contains(local.regions, "us-west-2") == true ? 1 : 0
  name          = "alias/${var.resource_prefix}"
  target_key_id = aws_kms_key.kms_us_west_2.0.key_id
  provider      = aws.oregon
}

# ## AF-SOUTH-1
# resource "aws_kms_key" "kms_af_south_1" {
#   count               = contains(local.regions, "af-south-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.cape-town
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_af_south_1" {
#   count         = contains(local.regions, "af-south-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_af_south_1.0.key_id
#   provider      = aws.cape-town
# }

# ## AP-EAST-1
# resource "aws_kms_key" "kms_ap_east_1" {
#   count               = contains(local.regions, "ap-east-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.hongkong
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_ap_east_1" {
#   count         = contains(local.regions, "ap-east-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_ap_east_1.0.key_id
#   provider      = aws.hongkong
# }

# ## AP-SOUTH-1
# resource "aws_kms_key" "kms_ap_south_1" {
#   count               = contains(local.regions, "ap-south-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.mumbai
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_ap_south_1" {
#   count         = contains(local.regions, "ap-south-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_ap_south_1.0.key_id
#   provider      = aws.mumbai
# }

# ## AP-NORTHEAST-2
# resource "aws_kms_key" "kms_ap_northeast_2" {
#   count               = contains(local.regions, "ap-northeast-2") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.osaka
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_ap_northeast_2" {
#   count         = contains(local.regions, "ap-northeast-2") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_ap_northeast_2.0.key_id
#   provider      = aws.osaka
# }

# ## AP-SOUTHEAST-1 

# resource "aws_kms_key" "kms_ap_southeast_1" {
#   count               = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.singapore
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_ap_southeast_1" {
#   count         = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_ap_southeast_1.0.key_id
#   provider      = aws.singapore
# }

# ## AP-SOUTHEAST-2

# resource "aws_kms_key" "kms_ap_southeast_2" {
#   count               = contains(local.regions, "ap-southeast-2") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.sydney
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_ap_southeast_2" {
#   count         = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_ap_southeast_2.0.key_id
#   provider      = aws.sydney
# }

# ## AP-NORTHEAST-1

# resource "aws_kms_key" "kms_ap_northeast_1" {
#   count               = contains(local.regions, "ap-northeast-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.tokyo
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_ap_northeast_1" {
#   count         = contains(local.regions, "ap-northeast-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_ap_northeast_1.0.key_id
#   provider      = aws.tokyo
# }

# ## CA-CENTRAL-1

# resource "aws_kms_key" "kms_ca_central_1" {
#   count               = contains(local.regions, "ca-central-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.central
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_ca_central_1" {
#   count         = contains(local.regions, "ca-central-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_ca_central_1.0.key_id
#   provider      = aws.central
# }


# ## EU-CENTRAL-1

# resource "aws_kms_key" "kms_eu_central_1" {
#   count               = contains(local.regions, "eu-central-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.frankfurt
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_eu_central_1" {
#   count         = contains(local.regions, "eu-central-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_eu_central_1.0.key_id
#   provider      = aws.frankfurt
# }


# ## EU-WEST-1

# resource "aws_kms_key" "kms_eu_west_1" {
#   count               = contains(local.regions, "eu-west-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.ireland
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_eu_west_1" {
#   count         = contains(local.regions, "eu-west-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_eu_west_1.0.key_id
#   provider      = aws.ireland
# }

# ## EU-WEST-2

# resource "aws_kms_key" "kms_eu_west_2" {
#   count               = contains(local.regions, "eu-west-2") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.london
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_eu_west_2" {
#   count         = contains(local.regions, "eu-west-2") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_eu_west_1.0.key_id
#   provider      = aws.london
# }

# ## EU-SOUTH-1

# resource "aws_kms_key" "kms_eu_south_1" {
#   count               = contains(local.regions, "eu-south-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.milan
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_eu_south_1" {
#   count         = contains(local.regions, "eu-south-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_eu_south_1.0.key_id
#   provider      = aws.milan
# }


# ## EU-WEST-3

# resource "aws_kms_key" "kms_eu_west_3" {
#   count               = contains(local.regions, "eu-west-3") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.paris
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_eu_west_3" {
#   count         = contains(local.regions, "eu-west-3") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_eu_south_1.0.key_id
#   provider      = aws.paris
# }


# ## EU-NORTH-1

# resource "aws_kms_key" "kms_eu_north_1" {
#   count               = contains(local.regions, "eu-north-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.stockholm
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_eu_north_1" {
#   count         = contains(local.regions, "eu-north-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_eu_north_1.0.key_id
#   provider      = aws.stockholm
# }


# ## ME-SOUTH-1

# resource "aws_kms_key" "kms_me_south_1" {
#   count               = contains(local.regions, "me-south-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.bahrain
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_me_south_1" {
#   count         = contains(local.regions, "me-south-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_me_south_1.0.key_id
#   provider      = aws.bahrain
# }

# ## SA-EAST-1

# resource "aws_kms_key" "kms_sa_east_1" {
#   count               = contains(local.regions, "sa-east-1") == true ? 1 : 0
#   description         = "Encryption key for ${var.resource_prefix}"
#   enable_key_rotation = true
#   provider            = aws.sao-paulo
#   tags                = local.tags
# }

# resource "aws_kms_alias" "kms_sa_east_1" {
#   count         = contains(local.regions, "sa-east-1") == true ? 1 : 0
#   name          = "alias/${var.resource_prefix}"
#   target_key_id = aws_kms_key.kms_sa_east_1.0.key_id
#   provider      = aws.sao-paulo
# }
