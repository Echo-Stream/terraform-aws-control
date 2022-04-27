/*
 Notifications

Amazon SES can send you detailed notifications about your bounces, complaints, and deliveries.
Bounce and complaint notifications are available by email or through Amazon Simple Notification Service (Amazon SNS). By default, these notifications are sent to you via email by a feature called email feedback forwarding.
Delivery notifications, which are sent when Amazon SES successfully delivers one of your emails to a recipient's mail server, are optional and only available through Amazon SNS.



Current notification configuration:
Email Feedback Forwarding: 	enabled
Bounce Notifications SNS Topic: 	none	
Complaint Notifications SNS Topic: 	none
Delivery Notifications SNS Topic: 	none
Include Original Headers: 	disabled
*/

data "aws_ses_email_identity" "support" {
  email = var.ses_email_address
}

resource "aws_ses_configuration_set" "email_errors" {
  name = "${var.resource_prefix}-email-errors"
}

resource "aws_ses_event_destination" "email_errors" {
  configuration_set_name = aws_ses_configuration_set.email_errors.name
  enabled                = true
  matching_types         = ["bounce", "reject", "renderingFailure", "complaint"]
  name                   = "${var.resource_prefix}-email-errors-sns"

  sns_destination {
    topic_arn = aws_sns_topic.email_error_events.arn
  }
}

resource "aws_sns_topic" "email_error_events" {
  name         = "${var.resource_prefix}-email-error-events"
  display_name = "Email error sending events (bounces, complaints and rejected emails) "
  tags         = local.tags
}

resource "aws_ses_template" "invite_user" {
  name    = "${var.resource_prefix}-invite-user"
  subject = "Welcome to EchoStream!"
  html    = file("${path.module}/files/invite-user.html")
  text    = file("${path.module}/files/invite-user.txt")
}

resource "aws_ses_template" "notify_user" {
  name    = "${var.resource_prefix}-notify-user"
  subject = "Welcome {{name}} to EchoStream Tenant {{tenant}}"
  html    = file("${path.module}/files/notify-user.html")
  text    = file("${path.module}/files/notify-user.txt")
}

resource "aws_ses_template" "remove_user" {
  name    = "${var.resource_prefix}-remove-user"
  subject = "Goodbye {{name}} from EchoStream Tenant {{tenant}}"
  html    = file("${path.module}/files/remove-user.html")
  text    = file("${path.module}/files/remove-user.txt")
}

resource "aws_ses_template" "managed_app_cloud_init_notify" {
  name    = "${var.resource_prefix}-managed-app-cloud-init-notify"
  subject = "Managed instance {{ managed_instance_id }} is sucessfully registered!"
  html    = file("${path.module}/files/managed-app-cloud-init-notify.html")
  text    = file("${path.module}/files/managed-app-cloud-init-notify.txt")
}

resource "aws_ses_template" "tenant_created" {
  name    = "${var.resource_prefix}-tenant-created"
  subject = "EchoStream Tenant {{tenant}} is sucessfully created!"
  html    = file("${path.module}/files/tenant-created.html")
  text    = file("${path.module}/files/tenant-created.txt")
}

resource "aws_ses_template" "tenant_deleted" {
  name    = "${var.resource_prefix}-tenant-deleted"
  subject = "EchoStream Tenant {{tenant}} is sucessfully deleted!"
  html    = file("${path.module}/files/tenant-deleted.html")
  text    = file("${path.module}/files/tenant-deleted.txt")
}

resource "aws_ses_template" "tenant_errored" {
  name    = "${var.resource_prefix}-tenant-errored"
  subject = "EchoStream Tenant {{tenant}} creation was unsuccessful!"
  html    = file("${path.module}/files/tenant-errored.html")
  text    = file("${path.module}/files/tenant-errored.txt")
}