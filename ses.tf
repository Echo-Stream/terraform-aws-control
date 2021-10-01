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
resource "aws_ses_email_identity" "support" {
  email = var.ses_email_address
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