data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_s3_bucket" "log_bucket" {
  bucket = local.log_bucket
}

data "aws_route53_zone" "root_domain" {
  name         = var.domain_name
  private_zone = false
  provider     = aws.route-53
}

data "aws_iam_policy" "administrator_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

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

data "aws_iam_policy_document" "edge_lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "aws_glue_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["glue.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "state_machine_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = [
        "states.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["glue.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "dynamodb_replication_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["replication.dynamodb.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_lambda_layer_version" "aws_data_wranlger" {
  layer_name  = "AWSDataWrangler-Python39"
  version     = 9
}
