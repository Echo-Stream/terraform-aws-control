resource "aws_ses_email_identity" "support" {
  email = var.ses_email_address
}

resource "aws_ses_template" "invite_user" {
  name    = "${var.resource_prefix}-invite-user"
  subject = "Invitation from EchoStream"
  html    = file("${path.module}/files/Lorem-Ipsum-All-the-facts-Lipsum-generator.html")
}

resource "aws_ses_template" "notify_user" {
  name    = "${var.resource_prefix}-notify-user"
  subject = "Notification from EchoStream"
  html    = file("${path.module}/files/Lorem-Ipsum-All-the-facts-Lipsum-generator.html")
}

resource "aws_ses_template" "remove_user" {
  name    = "${var.resource_prefix}-remove-user"
  subject = "Goodbye from EchoStream"
  html    = file("${path.module}/files/Lorem-Ipsum-All-the-facts-Lipsum-generator.html")
}