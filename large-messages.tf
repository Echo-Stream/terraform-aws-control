resource "aws_iam_user" "presign_bulk_data" {
  name = "${var.resource_prefix}-presign-bulk-data"
  path = "/lambda/"

  tags = merge(local.tags, {
    lambda = "${var.resource_prefix}-appsync-large-message-storage-datasource"
  })
}

data "aws_iam_policy_document" "presign_bulk_data" {
  statement {
    actions = [
      "s3:GetObject*",
      "s3:PutObject*",
    ]

    resources = flatten([
      [for lmb in module.bulk_data_bucket_us_east_1 : "${lmb.arn}/*"],
      [for lmb in module.bulk_data_bucket_us_east_2 : "${lmb.arn}/*"],
      [for lmb in module.bulk_data_bucket_us_west_2 : "${lmb.arn}/*"]
    ])

    sid = "LargeMessagesBucketsAccess"
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
    ]

    resources = flatten([
      aws_kms_key.kms_us_east_1[*].arn,
      aws_kms_key.kms_us_east_2[*].arn,
      aws_kms_key.kms_us_west_2[*].arn
    ])

    sid = "EncryptDecryptEnvKMSKeys"
  }
}


resource "aws_iam_user_policy" "presign_bulk_data" {
  user   = aws_iam_user.presign_bulk_data.name
  policy = data.aws_iam_policy_document.presign_bulk_data.json
}

resource "aws_iam_access_key" "presign_bulk_data" {
  user = aws_iam_user.presign_bulk_data.name
}

############################
## Large Messages Buckets ##
############################


## US-EAST-1
module "bulk_data_bucket_us_east_1" {
  count       = contains(local.regions, "us-east-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-us-east-1"
  kms_key_arn = aws_kms_key.kms_us_east_1.0.arn
  log_bucket  = module.log_bucket_us_east_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.north-virginia
  }

  source = "./_modules/bulk-data-buckets"
}

## US-EAST-2
module "bulk_data_bucket_us_east_2" {
  count       = contains(local.regions, "us-east-2") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-us-east-2"
  kms_key_arn = aws_kms_key.kms_us_east_2.0.arn
  log_bucket  = module.log_bucket_us_east_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.ohio
  }

  source = "./_modules/bulk-data-buckets"
}

## US-WEST-1
module "bulk_data_bucket_us_west_1" {
  count       = contains(local.regions, "us-west-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-us-west-1"
  kms_key_arn = aws_kms_key.kms_us_west_1.0.arn
  log_bucket  = module.log_bucket_us_west_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.north-california
  }

  source = "./_modules/bulk-data-buckets"
}

## US-WEST-2
module "bulk_data_bucket_us_west_2" {
  count       = contains(local.regions, "us-west-2") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-us-west-2"
  kms_key_arn = aws_kms_key.kms_us_west_2.0.arn
  log_bucket  = module.log_bucket_us_west_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.oregon
  }

  source = "./_modules/bulk-data-buckets"
}

## AF-SOUTH-1

module "bulk_data_bucket_af_south_1" {
  count       = contains(local.regions, "af-south-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-af-south-1"
  kms_key_arn = aws_kms_key.kms_af_south_1.0.arn
  log_bucket  = module.log_bucket_af_south_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.cape-town
  }

  source = "./_modules/bulk-data-buckets"
}


## AP-EAST-1

module "bulk_data_bucket_ap_east_1" {
  count       = contains(local.regions, "ap-east-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-ap-east-1"
  kms_key_arn = aws_kms_key.kms_ap_east_1.0.arn
  log_bucket  = module.log_bucket_ap_east_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.hongkong
  }

  source = "./_modules/bulk-data-buckets"
}

## AP-SOUTH-1

module "bulk_data_bucket_ap_south_1" {
  count       = contains(local.regions, "ap-south-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-ap-south-1"
  kms_key_arn = aws_kms_key.kms_ap_south_1.0.arn
  log_bucket  = module.log_bucket_ap_south_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.mumbai
  }

  source = "./_modules/bulk-data-buckets"
}


## AP-NORTHEAST-2

module "bulk_data_bucket_ap_northeast_2" {
  count       = contains(local.regions, "ap-northeast-2") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-ap-northeast-2"
  kms_key_arn = aws_kms_key.kms_ap_northeast_2.0.arn
  log_bucket  = module.log_bucket_ap_northeast_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.osaka
  }

  source = "./_modules/bulk-data-buckets"
}


## AP-SOUTHEAST-1

module "bulk_data_bucket_ap_southeast_1" {
  count       = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-ap-southeast-1"
  kms_key_arn = aws_kms_key.kms_ap_southeast_1.0.arn
  log_bucket  = module.log_bucket_ap_southeast_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.singapore
  }

  source = "./_modules/bulk-data-buckets"
}

## AP-SOUTHEAST-2

module "bulk_data_bucket_ap_southeast_2" {
  count       = contains(local.regions, "ap-southeast-2") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-ap-southeast-2"
  kms_key_arn = aws_kms_key.kms_ap_southeast_2.0.arn
  log_bucket  = module.log_bucket_ap_southeast_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.ap-southeast-2
  }

  source = "./_modules/bulk-data-buckets"
}

## AP-NORTHEAST-1

module "bulk_data_bucket_ap_northeast_1" {
  count       = contains(local.regions, "ap-northeast-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-ap-northeast-1"
  kms_key_arn = aws_kms_key.kms_ap_northeast_1.0.arn
  log_bucket  = module.log_bucket_ap_northeast_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.ap-northeast-1
  }

  source = "./_modules/bulk-data-buckets"
}

## CA-CENTRAL-1

module "bulk_data_bucket_ca_central_1" {
  count       = contains(local.regions, "ca-central-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-ca-central-1"
  kms_key_arn = aws_kms_key.kms_ca_central_1.0.arn
  log_bucket  = module.log_bucket_ca_central_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.ca-central-1
  }

  source = "./_modules/bulk-data-buckets"
}

## EU-CENTRAL-1

module "bulk_data_bucket_eu_central_1" {
  count       = contains(local.regions, "eu-central-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-eu-central-1"
  kms_key_arn = aws_kms_key.kms_eu_central_1.0.arn
  log_bucket  = module.log_bucket_eu_central_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-central-1
  }

  source = "./_modules/bulk-data-buckets"
}


## EU-WEST-1

module "bulk_data_bucket_eu_west_1" {
  count       = contains(local.regions, "eu-west-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-eu-west-1"
  kms_key_arn = aws_kms_key.kms_eu_west_1.0.arn
  log_bucket  = module.log_bucket_eu_west_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-west-1
  }

  source = "./_modules/bulk-data-buckets"
}

## EU-WEST-2

module "bulk_data_bucket_eu_west_2" {
  count       = contains(local.regions, "eu-west-2") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-eu-west-2"
  kms_key_arn = aws_kms_key.kms_eu_west_2.0.arn
  log_bucket  = module.log_bucket_eu_west_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-west-2
  }

  source = "./_modules/bulk-data-buckets"
}


## EU-SOUTH-1

module "bulk_data_bucket_eu_south_1" {
  count       = contains(local.regions, "eu-south-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-eu-south-1"
  kms_key_arn = aws_kms_key.kms_eu_south_1.0.arn
  log_bucket  = module.log_bucket_eu_south_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-south-1
  }

  source = "./_modules/bulk-data-buckets"
}


## EU-WEST-3

module "bulk_data_bucket_eu_west_3" {
  count       = contains(local.regions, "eu-west-3") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-eu-west-3"
  kms_key_arn = aws_kms_key.kms_eu_west_3.0.arn
  log_bucket  = module.log_bucket_eu_west_3.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-west-3
  }

  source = "./_modules/bulk-data-buckets"
}


## EU-NORTH-1

module "bulk_data_bucket_eu_north_1" {
  count       = contains(local.regions, "eu-north-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-eu-north-1"
  kms_key_arn = aws_kms_key.kms_eu_north_1.0.arn
  log_bucket  = module.log_bucket_eu_north_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-north-1
  }

  source = "./_modules/bulk-data-buckets"
}


## ME-SOUTH-1

module "bulk_data_bucket_me_south_1" {
  count       = contains(local.regions, "me-south-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-me-south-1"
  kms_key_arn = aws_kms_key.kms_me_south_1.0.arn
  log_bucket  = module.log_bucket_me_south_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.me-south-1
  }

  source = "./_modules/bulk-data-buckets"
}


## SA-EAST-1

module "bulk_data_bucket_sa_east_1" {
  count       = contains(local.regions, "sa-east-1") == true ? 1 : 0
  name        = "${var.resource_prefix}-bulk-data-sa-east-1"
  kms_key_arn = aws_kms_key.kms_sa_east_1.0.arn
  log_bucket  = module.log_bucket_sa_east_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.sa-east-1
  }

  source = "./_modules/bulk-data-buckets"
}