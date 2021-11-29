data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = [
        "firehose.amazonaws.com",
      ]

      type = "Service"
    }
  }
}