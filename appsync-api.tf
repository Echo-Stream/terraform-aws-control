####################
## GraphQL Schema ##
####################

data "aws_s3_bucket_object" "graphql_schema" {
  bucket = local.artifacts_bucket
  key    = "${local.artifacts["appsync"]}/schema.graphql"
}

resource "aws_appsync_graphql_api" "hl7_ninja" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.hl7_ninja_appsync.arn
    field_log_level          = "ERROR"
  }

  user_pool_config {
    default_action = "ALLOW"
    user_pool_id   = aws_cognito_user_pool.hl7_ninja_apps.id
  }

  additional_authentication_provider {
    authentication_type = "AMAZON_COGNITO_USER_POOLS"

    user_pool_config {
      user_pool_id = aws_cognito_user_pool.hl7_ninja_ui.id
    }
  }

  schema = data.aws_s3_bucket_object.graphql_schema.body

  name = "${var.environment_prefix}-api"
  tags = local.tags
}

resource "aws_iam_role" "hl7_ninja_appsync" {
  name               = "${var.environment_prefix}-appsync"
  assume_role_policy = data.aws_iam_policy_document.appsync_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "hl7_ninja_appsync" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
  role       = aws_iam_role.hl7_ninja_appsync.name
}