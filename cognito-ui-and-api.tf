## echostream-ui cognito pool
resource "aws_cognito_user_pool" "echostream_ui" {
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  auto_verified_attributes = [
    "email"
  ]


  device_configuration {
    device_only_remembered_on_user_prompt = true ## Set to always in the console by hand
  }                                              ## TF 14.5, aws plugin 3.26.0 doesn't support to set it to 'always'

  email_configuration {
    source_arn            = aws_ses_email_identity.support.arn
    from_email_address    = var.ses_email_address
    email_sending_account = "DEVELOPER"
  }

  email_verification_message = "Your verification code is {####}. "
  email_verification_subject = "Your verification code"

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      schema,
      device_configuration,
      account_recovery_setting
    ]
  }

  mfa_configuration = "ON"
  name              = "${var.resource_prefix}-ui"

  lambda_config {
    pre_sign_up        = module.ui_cognito_pre_signup.arn
    post_confirmation  = module.ui_cognito_post_confirmation.arn
    pre_authentication = module.ui_cognito_pre_authentication.arn
  }

  password_policy {
    minimum_length                   = 16
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 90
  }

  schema {
    attribute_data_type = "String"
    name                = "given_name"
    required            = true
  }

  schema {
    attribute_data_type = "String"
    name                = "family_name"
    required            = true
  }

  software_token_mfa_configuration {
    enabled = true
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  tags = local.tags
}

resource "aws_cognito_user_pool_client" "echostream_ui_userpool_client" {
  name                   = "${var.resource_prefix}-reactjs"
  refresh_token_validity = 60

  supported_identity_providers = [
    "COGNITO",
  ]

  user_pool_id = aws_cognito_user_pool.echostream_ui.id

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

## Amazon Cognito domain, Will be a Custom Domain in Future

resource "aws_cognito_user_pool_domain" "echostream_amazon_cognito_domain" {
  domain       = var.resource_prefix
  user_pool_id = aws_cognito_user_pool.echostream_ui.id
}

## API userpool
resource "aws_cognito_user_pool" "echostream_api" {
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

  name = "${var.resource_prefix}-api"

  lambda_config {
    pre_authentication = module.api_cognito_pre_authentication.arn
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

resource "aws_cognito_user_pool_client" "echostream_api_userpool_client" {
  access_token_validity  = 60
  id_token_validity      = 60
  name                   = "${var.resource_prefix}-api"
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  supported_identity_providers = [
    "COGNITO",
  ]

  user_pool_id = aws_cognito_user_pool.echostream_api.id

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}