resource "aws_iam_user" "presign_large_messages" {
  name = "${var.environment_prefix}-presign-large-messages"
  path = "/lambda/"

  tags = merge(local.tags, {
    lambda = "${var.environment_prefix}-appsync-large-message-storage-datasource"
  })
}

data "aws_iam_policy_document" "presign_large_messages" {
  statement {
    actions = [
      "s3:GetObject*",
      "s3:PutObject*",
    ]

    resources = flatten([
      [for lmb in module.large_messages_bucket_us_east_1 : "${lmb.arn}/*"],
      [for lmb in module.large_messages_bucket_us_east_2 : "${lmb.arn}/*"],
      [for lmb in module.large_messages_bucket_us_west_2 : "${lmb.arn}/*"]
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


resource "aws_iam_user_policy" "presign_large_messages" {
  user   = aws_iam_user.presign_large_messages.name
  policy = data.aws_iam_policy_document.presign_large_messages.json
}

resource "aws_iam_access_key" "presign_large_messages" {
  user = aws_iam_user.presign_large_messages.name
}

############################
## Large Messages Buckets ##
############################


## US-EAST-1
module "large_messages_bucket_us_east_1" {
  count       = contains(local.regions, "us-east-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-us-east-1"
  kms_key_arn = aws_kms_key.kms_us_east_1.0.arn
  log_bucket  = module.log_bucket_us_east_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.us-east-1
  }

  source = "./_modules/large-messages-buckets"
}

## US-EAST-2
module "large_messages_bucket_us_east_2" {
  count       = contains(local.regions, "us-east-2") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-us-east-2"
  kms_key_arn = aws_kms_key.kms_us_east_2.0.arn
  log_bucket  = module.log_bucket_us_east_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.us-east-2
  }

  source = "./_modules/large-messages-buckets"
}

## US-WEST-2
module "large_messages_bucket_us_west_2" {
  count       = contains(local.regions, "us-west-2") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-us-west-2"
  kms_key_arn = aws_kms_key.kms_us_west_2.0.arn
  log_bucket  = module.log_bucket_us_west_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.us-west-2
  }

  source = "./_modules/large-messages-buckets"
}

## US-WEST-1
module "large_messages_bucket_us_west_1" {
  count       = contains(local.regions, "us-west-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-us-west-1"
  kms_key_arn = aws_kms_key.kms_us_west_1.0.arn
  log_bucket  = module.log_bucket_us_west_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.us-west-1
  }

  source = "./_modules/large-messages-buckets"
}

## US-WEST-2
module "large_messages_bucket_us_west_2" {
  count       = contains(local.regions, "us-west-2") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-us-west-2"
  kms_key_arn = aws_kms_key.kms_us_west_2.0.arn
  log_bucket  = module.log_bucket_us_west_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.us-west-2
  }

  source = "./_modules/large-messages-buckets"
}


## AF-SOUTH-1

module "large_messages_bucket_af_south_1" {
  count       = contains(local.regions, "af-south-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-af-south-1"
  kms_key_arn = aws_kms_key.kms_af_south_1.0.arn
  log_bucket  = module.log_bucket_af_south_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.af-south-1
  }

  source = "./_modules/large-messages-buckets"
}


## AP-EAST-1

module "large_messages_bucket_ap_east_1" {
  count       = contains(local.regions, "ap-east-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-ap-east-1"
  kms_key_arn = aws_kms_key.kms_ap_east_1.0.arn
  log_bucket  = module.log_bucket_ap_east_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.ap-east-1
  }

  source = "./_modules/large-messages-buckets"
}

## AP-SOUTH-1

module "large_messages_bucket_ap_south_1" {
  count       = contains(local.regions, "ap-south-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-ap-south-1"
  kms_key_arn = aws_kms_key.kms_ap_south_1.0.arn
  log_bucket  = module.log_bucket_ap_south_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.ap-south-1
  }

  source = "./_modules/large-messages-buckets"
}


## AP-NORTHEAST-2

module "large_messages_bucket_ap_northeast_2" {
  count       = contains(local.regions, "ap-northeast-2") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-ap-northeast-2"
  kms_key_arn = aws_kms_key.kms_ap_northeast_2.0.arn
  log_bucket  = module.log_bucket_ap_northeast_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.ap-northeast-2
  }

  source = "./_modules/large-messages-buckets"
}


## AP-SOUTHEAST-1

module "large_messages_bucket_ap_southeast_1" {
  count       = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-ap-southeast-1"
  kms_key_arn = aws_kms_key.kms_ap_southeast_1.0.arn
  log_bucket  = module.log_bucket_ap_southeast_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.ap-southeast-1
  }

  source = "./_modules/large-messages-buckets"
}

## AP-SOUTHEAST-2

module "large_messages_bucket_ap_southeast_2" {
  count       = contains(local.regions, "ap-southeast-2") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-ap-southeast-2"
  kms_key_arn = aws_kms_key.kms_ap_southeast_2.0.arn
  log_bucket  = module.log_bucket_ap_southeast_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.ap-southeast-2
  }

  source = "./_modules/large-messages-buckets"
}

## AP-NORTHEAST-1

module "large_messages_bucket_ap_northeast_1" {
  count       = contains(local.regions, "ap-northeast-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-ap-northeast-1"
  kms_key_arn = aws_kms_key.kms_ap_northeast_1.0.arn
  log_bucket  = module.log_bucket_ap_northeast_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.ap-northeast-1
  }

  source = "./_modules/large-messages-buckets"
}

## CA-CENTRAL-1

module "large_messages_bucket_ca_central_1" {
  count       = contains(local.regions, "ca-central-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-ca-central-1"
  kms_key_arn = aws_kms_key.kms_ca_central_1.0.arn
  log_bucket  = module.log_bucket_ca_central_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.ca-central-1
  }

  source = "./_modules/large-messages-buckets"
}

## EU-CENTRAL-1

module "large_messages_bucket_eu_central_1" {
  count       = contains(local.regions, "eu-central-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-eu-central-1"
  kms_key_arn = aws_kms_key.kms_eu_central_1.0.arn
  log_bucket  = module.log_bucket_eu_central_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-central-1
  }

  source = "./_modules/large-messages-buckets"
}


## EU-WEST-1

module "large_messages_bucket_eu_west_1" {
  count       = contains(local.regions, "eu-west-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-eu-west-1"
  kms_key_arn = aws_kms_key.kms_eu_west_1.0.arn
  log_bucket  = module.log_bucket_eu_west_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-west-1
  }

  source = "./_modules/large-messages-buckets"
}

## EU-WEST-2

module "large_messages_bucket_eu_west_2" {
  count       = contains(local.regions, "eu-west-2") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-eu-west-2"
  kms_key_arn = aws_kms_key.kms_eu_west_2.0.arn
  log_bucket  = module.log_bucket_eu_west_2.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-west-2
  }

  source = "./_modules/large-messages-buckets"
}


## EU-SOUTH-1

module "large_messages_bucket_eu_south_1" {
  count       = contains(local.regions, "eu-south-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-eu-south-1"
  kms_key_arn = aws_kms_key.kms_eu_south_1.0.arn
  log_bucket  = module.log_bucket_eu_south_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-south-1
  }

  source = "./_modules/large-messages-buckets"
}


## EU-WEST-3

module "large_messages_bucket_eu_west_3" {
  count       = contains(local.regions, "eu-west-3") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-eu-west-3"
  kms_key_arn = aws_kms_key.kms_eu_west_3.0.arn
  log_bucket  = module.log_bucket_eu_west_3.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-west-3
  }

  source = "./_modules/large-messages-buckets"
}


## EU-NORTH-1

module "large_messages_bucket_eu_north_1" {
  count       = contains(local.regions, "eu-north-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-eu-north-1"
  kms_key_arn = aws_kms_key.kms_eu_north_1.0.arn
  log_bucket  = module.log_bucket_eu_north_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.eu-north-1
  }

  source = "./_modules/large-messages-buckets"
}


## ME-SOUTH-1

module "large_messages_bucket_me_south_1" {
  count       = contains(local.regions, "me-south-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-me-south-1"
  kms_key_arn = aws_kms_key.kms_me_south_1.0.arn
  log_bucket  = module.log_bucket_me_south_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.me-south-1
  }

  source = "./_modules/large-messages-buckets"
}


## SA-EAST-1

module "large_messages_bucket_sa_east_1" {
  count       = contains(local.regions, "sa-east-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-sa-east-1"
  kms_key_arn = aws_kms_key.kms_sa_east_1.0.arn
  log_bucket  = module.log_bucket_sa_east_1.0.id
  tags        = local.tags

  providers = {
    aws = aws.sa-east-1
  }

  source = "./_modules/large-messages-buckets"
}