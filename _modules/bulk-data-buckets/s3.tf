############################
## Large Messages Buckets ##
############################
resource "aws_s3_bucket" "bulk_data" {
  acl    = "private"
  bucket = var.name

  # lifecycle {
  #   prevent_destroy = true
  # }

  lifecycle_rule {
    id      = "expire"
    prefix  = "/"
    enabled = true

    expiration {
      days = 7
    }

    noncurrent_version_expiration {
      days = 7
    }
  }

  logging {
    target_bucket = var.log_bucket
    target_prefix = "s3/${var.name}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

data "aws_iam_policy_document" "bulk_data" {
  statement {
    actions = [
      "s3:*",
    ]

    condition {
      test = "Bool"
      values = [
        "false",
      ]
      variable = "aws:SecureTransport"
    }

    effect = "Deny"

    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }

    resources = [
      aws_s3_bucket.bulk_data.arn,
      "${aws_s3_bucket.bulk_data.arn}/*",
    ]
    sid = "DenyUnsecuredTransport"
  }

  statement {
    actions = [
      "s3:PutObject*",
    ]

    condition {
      test = "StringEquals"
      values = [
        "AES256",
      ]
      variable = "s3:x-amz-server-side-encryption"
    }

    effect = "Deny"

    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }

    resources = [
      "${aws_s3_bucket.bulk_data.arn}/*",
    ]
    sid = "DenySSEWithAES"
  }

  statement {
    actions = [
      "s3:PutObject*"
    ]

    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }

    effect = "Deny"

    condition {
      test = "StringNotLikeIfExists"

      values = [
        var.kms_key_arn
      ]

      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
    }

    resources = [
      "${aws_s3_bucket.bulk_data.arn}/*",
    ]

    sid = "RequiresEnvironmentKMSKeyEncryption"
  }
}

resource "aws_s3_bucket_policy" "bulk_data" {
  bucket = aws_s3_bucket.bulk_data.id
  policy = data.aws_iam_policy_document.bulk_data.json
}

## Block public access (bucket settings)
resource "aws_s3_bucket_public_access_block" "bulk_data" {
  bucket                  = aws_s3_bucket.bulk_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}