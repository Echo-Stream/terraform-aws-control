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