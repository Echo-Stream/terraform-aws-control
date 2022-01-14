data "aws_iam_policy_document" "presign_bulk_data" {
  statement {
    actions = [
      "s3:GetObject*",
      "s3:PutObject*",
    ]

    resources = [
      "arn:aws:s3:::${var.resource_prefix}-tenant-*",
    ]

    sid = "PutGetObjectsInTenantBuckets"
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
    ]

    resources = [
      "arn:aws:kms:${var.region}:${var.allowed_account_id}:key/*"
    ]

    sid = "EncryptDecryptObjectsUsingTenantKeys"
  }
}

resource "aws_iam_policy" "presign_bulk_data" {
  description = "IAM permissions required for presign-bulk-data"
  name        = "${var.resource_prefix}-presign-bulk-data"
  policy      = data.aws_iam_policy_document.presign_bulk_data.json
}

resource "aws_iam_user_policy_attachment" "presign_bulk_data" {
  user       = aws_iam_user.presign_bulk_data.name
  policy_arn = aws_iam_policy.presign_bulk_data.arn
}

resource "aws_iam_user" "presign_bulk_data" {
  name = "${var.resource_prefix}-presign-bulk-data"
  tags = local.tags
}

resource "aws_iam_access_key" "presign_bulk_data" {
  user = aws_iam_user.presign_bulk_data.name
}
