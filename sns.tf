resource "aws_sns_topic" "alarms" {
  name         = "${var.resource_prefix}-alarms"
  display_name = "${var.resource_prefix} Alarms"
  tags         = local.tags
}

resource "aws_sns_topic_subscription" "alarms" {
  endpoint  = data.aws_ses_email_identity.support.email
  protocol  = "email"
  topic_arn = aws_sns_topic.alarms.arn
}

resource "aws_sns_topic" "ci_cd_errors" {
  name         = "${var.resource_prefix}-ci-cd-errors"
  display_name = "${var.resource_prefix} CI/CD Notifications"
  tags         = local.tags
}

resource "aws_sns_topic_subscription" "ci_cd_errors" {
  endpoint  = data.aws_ses_email_identity.support.email
  protocol  = "email"
  topic_arn = aws_sns_topic.ci_cd_errors.arn
}

resource "aws_sns_topic_policy" "ci_cd_errors" {
  arn    = aws_sns_topic.ci_cd_errors.arn
  policy = data.aws_iam_policy_document.ci_cd_errors.json
}

data "aws_iam_policy_document" "ci_cd_errors" {
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
        data.aws_caller_identity.current.account_id
      ]
      variable = "AWS:SourceOwner"
    }
  }
}

resource "aws_sns_topic" "rebuild_notification_failures" {
  name         = "${var.resource_prefix}-rebuild-notification-failures"
  display_name = "${var.resource_prefix} Rebuild Notification Failures"
  tags         = local.tags
}
