resource "random_string" "echostream_ui_external_id" {
  length  = 36
  lower   = true
  number  = true
  special = false
  upper   = true
}

data "aws_iam_policy_document" "cognito_sms_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    condition {
      test = "StringEquals"

      values = [
        random_string.echostream_ui_external_id.result,
      ]

      variable = "sts:ExternalId"
    }

    principals {
      identifiers = [
        "cognito-idp.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

resource "aws_iam_role" "cognito_sms" {
  assume_role_policy = data.aws_iam_policy_document.cognito_sms_assume_role.json
  name               = "${var.resource_prefix}-ui-cognito-sms"
  tags               = local.tags
}

data "aws_iam_policy_document" "cognito_sms" {
  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "cognito_sms" {
  policy = data.aws_iam_policy_document.cognito_sms.json
  role   = aws_iam_role.cognito_sms.id
}

resource "aws_cognito_user_pool" "echostream_apps" {
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

  name = "${var.resource_prefix}-apps"

  lambda_config {
    pre_authentication   = module.app_cognito_pre_authentication.arn
    pre_token_generation = module.app_cognito_pre_token_generation.arn
  }

  password_policy {
    minimum_length                   = 16
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = 90
  }

  tags = local.tags
}

resource "aws_cognito_user_pool_client" "echostream_apps_userpool_client" {
  name                   = "${var.resource_prefix}-apps"
  refresh_token_validity = 30

  supported_identity_providers = [
    "COGNITO",
  ]

  user_pool_id = aws_cognito_user_pool.echostream_apps.id

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

### echostream-ui cognito pool
resource "aws_cognito_user_pool" "echostream_ui" {

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    # recovery_mechanism {
    #   name     = "verified_phone_number"
    #   priority = 2
    # }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  auto_verified_attributes = [
    "email"
  ]

  email_verification_message = "Your verification code is {####}. "
  email_verification_subject = "Your verification code"

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      schema
    ]
  }

  mfa_configuration = "OPTIONAL"
  name              = "${var.resource_prefix}-ui"

  lambda_config {
    pre_sign_up          = module.ui_cognito_pre_signup.arn
    post_confirmation    = module.ui_cognito_post_signup.arn
    pre_authentication   = module.ui_cognito_pre_authentication.arn
    pre_token_generation = module.ui_cognito_pre_token_generation.arn
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

  # sms_authentication_message = "Your authentication code is {####}. "

  # sms_configuration {
  #   external_id    = random_string.echostream_ui_external_id.result
  #   sns_caller_arn = aws_iam_role.cognito_sms.arn
  # }

  #sms_verification_message = "Your verification code is {####}. "

  username_attributes = [
    "email",
  ]

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  software_token_mfa_configuration {
    enabled = true
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }

  tags = local.tags
}

resource "aws_cognito_user_pool_client" "echostream_ui_userpool_client" {
  name                   = "${var.resource_prefix}-reactjs"
  refresh_token_validity = 30

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
    pre_authentication   = module.api_cognito_pre_authentication.arn
    pre_token_generation = module.api_cognito_pre_token_generation.arn
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
  name                   = "${var.resource_prefix}-api"
  refresh_token_validity = 30

  supported_identity_providers = [
    "COGNITO",
  ]

  user_pool_id = aws_cognito_user_pool.echostream_api.id

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

