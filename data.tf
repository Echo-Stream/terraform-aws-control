data "aws_region" "current" {}

data "aws_iam_policy_document" "appsync_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "appsync.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

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

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "lambda.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

data "aws_s3_bucket" "artifacts" {
  bucket = local.artifacts_bucket
}