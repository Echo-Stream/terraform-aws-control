############################
## Large Messages Buckets ##
############################
resource "aws_s3_bucket" "large_messages" {
  acl    = "private"
  bucket = var.name

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

# data "aws_iam_policy_document" "large_messages" {
#   statement {
#     actions = [
#       "s3:*",
#     ]

#     condition {
#       test = "Bool"
#       values = [
#         "false",
#       ]
#       variable = "aws:SecureTransport"
#     }

#     effect = "Deny"

#     principals {
#       identifiers = [
#         "*",
#       ]
#       type = "AWS"
#     }

#     resources = [
#       aws_s3_bucket.large_messages.arn,
#       "${aws_s3_bucket.large_messages.arn}/*",
#     ]
#     sid = "DenyUnsecuredTransport"
#   }

#   statement {
#     actions = [
#       "s3:PutObject*"
#     ]

#     principals {
#       identifiers = [
#         "*",
#       ]
#       type = "AWS"
#     }

#     condition {
#       test = "StringNotEquals"

#       values = [
#         "aws:kms"
#       ]

#       variable = "s3:x-amz-server-side-encryption"
#     }

#     resources = [
#       "${aws_s3_bucket.large_messages.arn}/*",
#     ]

#     sid = "DenyIncorrectEncryptionHeader"
#   }

#     statement {
#     actions = [
#       "s3:PutObject*"
#     ]

#     principals {
#       identifiers = [
#         "*",
#       ]
#       type = "AWS"
#     }

#     condition {
#       test = "Null"

#       values = [
#         "true"
#       ]

#       variable = "s3:x-amz-server-side-encryption"
#     }

#     resources = [
#       "${aws_s3_bucket.large_messages.arn}/*",
#     ]

#     sid = "DenyUnEncryptedObjectUploads"
#   }
# }

# resource "aws_s3_bucket_policy" "large_messages" {
#   bucket = aws_s3_bucket.large_messages.id
#   policy = data.aws_iam_policy_document.large_messages.json
# }

## Block public access (bucket settings)
resource "aws_s3_bucket_public_access_block" "large_messages" {
  bucket                  = aws_s3_bucket.large_messages.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}