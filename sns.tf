resource "aws_sns_topic" "hl7_app_cloud_init" {
  name         = "${var.environment_prefix}-hl7-app-cloud-init"
  display_name = "HL7 App Cloud Init topic"
  tags         = local.tags
}


module "hl7_app_cloud_init_subscription" {
  install_aws_cli = false
  topic_arn       = aws_sns_topic.hl7_app_cloud_init.arn
  email_address   = var.ses_email_address
  source          = "QuiNovas/sns-email-subscription/aws"
  version         = "0.0.1"
}
