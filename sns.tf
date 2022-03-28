resource "aws_sns_topic" "managed_app_cloud_init" {
  name         = "${var.resource_prefix}-managed-app-cloud-init"
  display_name = "Managed App Cloud Init topic"
  tags         = local.tags
}

module "managed_app_cloud_init_subscription" {
  install_aws_cli = false
  topic_arn       = aws_sns_topic.managed_app_cloud_init.arn
  email_address   = var.ses_email_address
  source          = "QuiNovas/sns-email-subscription/aws"
  version         = "0.0.2"
}

resource "aws_sns_topic" "ci_cd_errors" {
  name         = "${var.resource_prefix}-ci-cd-errors"
  display_name = "${var.resource_prefix} CI/CD Notifications"
  tags         = local.tags
}

resource "aws_sns_topic_policy" "ci_cd_errors" {
  arn    = aws_sns_topic.ci_cd_errors.arn
  policy = data.aws_iam_policy_document.ci_cd_errors.json
}

data "aws_iam_policy_document" "ci_cd_errors" {
  statement {
    sid     = "AWSEvents_stepfunctionFail"
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.ci_cd_errors.arn]
  }

  statement {
    sid     = "__default_statement_ID"
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.ci_cd_errors.arn]

    condition {
      test = "StringEquals"
      values = [
        var.allowed_account_id
      ]
      variable = "AWS:SourceOwner"
    }
  }
}