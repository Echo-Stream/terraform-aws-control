resource "aws_s3_bucket" "hl7_ninja_audit_records" {
  acl    = "private"
  bucket = "${var.environment_prefix}-audit-records"

  lifecycle {
    prevent_destroy = true
  }

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
resource "aws_s3_bucket_public_access_block" "hl7_ninja_audit_records" {
  bucket                  = aws_s3_bucket.hl7_ninja_audit_records.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}