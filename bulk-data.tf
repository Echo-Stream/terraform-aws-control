resource "aws_iam_user" "presign_bulk_data" {
  name = "${var.resource_prefix}-presign-bulk-data"
  tags = local.tags
}

resource "aws_iam_access_key" "presign_bulk_data" {
  user = aws_iam_user.presign_bulk_data.name
}
