resource "aws_cognito_user_pool" "echostream_app" {
  admin_create_user_config {
    allow_admin_create_user_only = true

    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}. "
      email_subject = "Your temporary password"
      sms_message   = "Your username is {username} and temporary password is {####}. "
    }
  }

  email_verification_message = "Your verification code is {####}. "
  email_verification_subject = "Your verification code"

  lifecycle {
    ignore_changes = [
      schema
    ]

    # prevent_destroy = true
  }

  name = "${var.name}-app"

  lambda_config {
    pre_authentication = module.app_cognito_pre_authentication.arn
  }

  password_policy {
    minimum_length                   = 60
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 90
  }

  tags = local.tags
}

resource "aws_cognito_user_pool_client" "echostream_app_userpool_client" {
  access_token_validity  = 60
  id_token_validity      = 60
  name                   = "${var.name}-app"
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  supported_identity_providers = [
    "COGNITO",
  ]

  user_pool_id = aws_cognito_user_pool.echostream_app.id

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}