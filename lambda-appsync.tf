

# additional-ddb-policy ##
data "aws_iam_policy_document" "additional_ddb_policy" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Query"
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*"
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "additional_ddb_policy" {
  description = "IAM permissions to read graph-table-dynamodb-trigger"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-additional-ddb-policy"
  policy      = data.aws_iam_policy_document.additional_ddb_policy.json
}

###########################
##  appsync--datasource  ##
###########################
data "aws_iam_policy_document" "appsync_datasource" {
  statement {
    actions = ["*"
    ]

    resources = ["*"]

    sid = "AdminLevel"
  }
}

resource "aws_iam_policy" "appsync_datasource" {
  description = "IAM permissions required for appsync-datasource lambda"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-appsync-datasource"
  policy      = data.aws_iam_policy_document.appsync_datasource.json
}

module "appsync_datasource" {
  description     = "The main datasource for the echo-stream API "
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = merge(local.common_lambda_environment_variables,
    {
      API_USER_POOL_CLIENT_ID = aws_cognito_user_pool_client.echostream_api_userpool_client.id
      API_USER_POOL_ID     = aws_cognito_user_pool.echostream_api.id
      #APP_IDENTITY_POOL_ID         = aws_cognito_identity_pool.echostream.id
      # APP_USER_POOL_APP_ID         = aws_cognito_user_pool_client.echostream_apps_userpool_client.id
      # APP_USER_POOL_ID             = aws_cognito_user_pool.echostream_apps.id
      MANAGED_APP_CLOUD_INIT_TOPIC = aws_sns_topic.managed_app_cloud_init.arn
      REMOTE_APP_ROLE              = aws_iam_role.remote_app.arn
      SSM_SERVICE_ROLE             = "service-role/${aws_iam_role.manage_apps_ssm_service_role.name}"
      UI_USER_POOL_ID              = aws_cognito_user_pool.echostream_ui.id
    }
  )

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.resource_prefix}-appsync-datasource"

  policy_arns = [
    aws_iam_policy.appsync_datasource.arn,
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 120
  version       = "3.0.14"
}