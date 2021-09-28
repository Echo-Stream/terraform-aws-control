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