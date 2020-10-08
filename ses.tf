resource "aws_ses_email_identity" "support" {
  email = var.ses_email_address
}

resource "aws_ses_template" "invite_user" {
  name    = "${var.environment_prefix}-invite-user"
  subject = "Invitation from hl7-ninja"
  html    = file("${path.module}/files/Lorem-Ipsum-All-the-facts-Lipsum-generator.html")
}

resource "aws_ses_template" "notify_user" {
  name    = "${var.environment_prefix}-notify-user"
  subject = "Notification from hl7-ninja"
  html    = file("${path.module}/files/Lorem-Ipsum-All-the-facts-Lipsum-generator.html")
}

resource "aws_ses_template" "remove_user" {
  name    = "${var.environment_prefix}-remove-user"
  subject = "Goodbye from hl7-ninja"
  html    = file("${path.module}/files/Lorem-Ipsum-All-the-facts-Lipsum-generator.html")
}