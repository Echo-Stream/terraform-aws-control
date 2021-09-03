resource "aws_cognito_identity_pool" "echostream" {
  identity_pool_name               = replace(var.resource_prefix, "/[^aA-zZ]/", "")
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.echostream_apps_userpool_client.id
    provider_name           = aws_cognito_user_pool.echostream_apps.endpoint
    server_side_token_check = false
  }

  tags = local.tags
}

# Authenticated IAM 
data "aws_iam_policy_document" "authenticated_id_pool_assume_role" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test = "StringEquals"

      values = [
        aws_cognito_identity_pool.echostream.id
      ]

      variable = "cognito-identity.amazonaws.com:aud"
    }

    condition {
      test = "ForAnyValue:StringLike"

      values = [
        "authenticated"
      ]

      variable = "cognito-identity.amazonaws.com:amr"
    }

    principals {
      identifiers = [
        "cognito-identity.amazonaws.com",
      ]

      type = "Federated"
    }
  }
}

resource "aws_iam_role" "authenticated" {
  description        = "Permissions to AWS for Authenticated Identities"
  assume_role_policy = data.aws_iam_policy_document.authenticated_id_pool_assume_role.json
  name               = "${var.resource_prefix}-authenticated-idp"
  tags               = local.tags
}

resource "aws_iam_role_policy" "authenticated" {
  policy = data.aws_iam_policy_document.authenticated_id_pool_policy.json
  role   = aws_iam_role.authenticated.id
}

data "aws_iam_policy_document" "authenticated_id_pool_policy" {
  statement {
    effect = "Allow"
    actions = [
      "cognito-sync:*",
      "cognito-identity:*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "firehose:PutRecord*"
    ]

    resources = [aws_kinesis_firehose_delivery_stream.process_audit_record_firehose.arn]

    sid = "WriteToFirehose"
  }
}

# Unauthenticated Role
data "aws_iam_policy_document" "unauthenticated_id_pool_policy" {
  statement {
    effect = "Allow"
    actions = [
      "cognito-sync:*",
    ]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "unauthenticated_id_pool_assume_role" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test = "StringEquals"

      values = [
        aws_cognito_identity_pool.echostream.id
      ]

      variable = "cognito-identity.amazonaws.com:aud"
    }

    condition {
      test = "ForAnyValue:StringLike"

      values = [
        "unauthenticated"
      ]

      variable = "cognito-identity.amazonaws.com:amr"
    }

    principals {
      identifiers = [
        "cognito-identity.amazonaws.com",
      ]

      type = "Federated"
    }
  }
}

resource "aws_iam_role" "unauthenticated" {
  description        = "Permissions to AWS for Unauthenticated Identities, typically belong to guest users"
  assume_role_policy = data.aws_iam_policy_document.unauthenticated_id_pool_assume_role.json
  name               = "${var.resource_prefix}-unauthenticated-idp"
  tags               = local.tags
}

resource "aws_iam_role_policy" "unauthenticated" {
  policy = data.aws_iam_policy_document.unauthenticated_id_pool_policy.json
  role   = aws_iam_role.unauthenticated.id
}

# Provides an AWS Cognito Identity Pool Roles Attachment
resource "aws_cognito_identity_pool_roles_attachment" "echostream" {
  identity_pool_id = aws_cognito_identity_pool.echostream.id

  roles = {
    "authenticated"   = aws_iam_role.authenticated.arn
    "unauthenticated" = aws_iam_role.unauthenticated.arn
  }
}