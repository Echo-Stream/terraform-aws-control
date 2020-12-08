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