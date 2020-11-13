resource "aws_s3_bucket" "audit_records" {
  acl    = "private"
  bucket = "${var.environment_prefix}-audit-records"

  # lifecycle {
  #   prevent_destroy = true
  # }

  lifecycle_rule {
    id      = "archive"
    prefix  = "/"
    enabled = true

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 3650
    }
  }

  logging {
    target_bucket = local.log_bucket
    target_prefix = "s3/${var.environment_prefix}-audit-records/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

## Block public access (bucket settings)
resource "aws_s3_bucket_public_access_block" "audit_records" {
  bucket                  = aws_s3_bucket.audit_records.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################
## Large Messages Buckets ##
############################


## US-EAST-1
module "large_messages_bucket_us_east_1" {
  count       = contains(local.regions, "us-east-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-us-east-1"
  kms_key_arn = aws_kms_key.kms_us_east_1.arn
  log_bucket  = module.log_bucket_us_east_1.id
  tags        = local.tags

  providers = {
    aws = aws.us-east-1
  }

  source = "./modules/large-messages-buckets"
}

## US-EAST-2
module "large_messages_bucket_us_east_2" {
  count       = contains(local.regions, "us-east-2") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-us-east-2"
  kms_key_arn = aws_kms_key.kms_us_east_2.arn
  log_bucket  = module.log_bucket_us_east_2.id
  tags        = local.tags

  providers = {
    aws = aws.us-east-2
  }

  source = "./modules/large-messages-buckets"
}

## US-WEST-1
module "large_messages_bucket_us_west_1" {
  count       = contains(local.regions, "us-west-1") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-us-west-1"
  kms_key_arn = aws_kms_key.kms_us_west_1.arn
  log_bucket  = module.log_bucket_us_west_1.id
  tags        = local.tags

  providers = {
    aws = aws.us-west-1
  }

  source = "./modules/large-messages-buckets"
}

## US-WEST-2
module "large_messages_bucket_us_west_2" {
  count       = contains(local.regions, "us-west-2") == true ? 1 : 0
  name        = "${var.environment_prefix}-large-messages-us-west-2"
  kms_key_arn = aws_kms_key.kms_us_west_2.arn
  log_bucket  = module.log_bucket_us_west_2.id
  tags        = local.tags

  providers = {
    aws = aws.us-west-2
  }

  source = "./modules/large-messages-buckets"
}