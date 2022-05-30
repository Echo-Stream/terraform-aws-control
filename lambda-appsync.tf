###########################
##  appsync-datasource  ##
###########################

locals {
  appsync_datasource_lambda_environment_variables = merge(local.common_lambda_environment_variables,
    {
      API_USER_POOL_CLIENT_ID         = aws_cognito_user_pool_client.echostream_api_userpool_client.id
      API_USER_POOL_ID                = aws_cognito_user_pool.echostream_api.id
      APP_USER_POOL_IDS               = local.app_user_pool_ids
      APP_USER_POOL_CLIENT_IDS        = local.app_user_pool_client_ids
      AUDIT_FIREHOSE_LOG_GROUP        = local.audit_firehose_log_group
      AUDIT_FIREHOSE_ROLE             = aws_iam_role.audit_firehose.arn
      BULK_DATA_AWS_ACCESS_KEY_ID     = aws_iam_access_key.presign_bulk_data.id
      BULK_DATA_AWS_SECRET_ACCESS_KEY = aws_iam_access_key.presign_bulk_data.secret
      BULK_DATA_IAM_USER              = aws_iam_user.presign_bulk_data.arn
      REGIONAL_APPSYNC_ENDPOINTS      = local.regional_appsync_endpoints
      REMOTE_APP_ROLE                 = aws_iam_role.remote_app.arn
      SSM_SERVICE_ROLE                = aws_iam_role.managed_app.name
      TENANT_DB_STREAM_HANDLER_ROLE   = module.graph_table_tenant_stream_handler.role_arn
      UI_USER_POOL_ID                 = aws_cognito_user_pool.echostream_ui.id
    }
  )

  appsync_api_ids = jsonencode({
    us-east-1 = aws_appsync_graphql_api.echostream.id
    us-east-2 = module.appsync_us_east_2.0.api_id
    us-west-1 = module.appsync_us_west_1.0.api_id
    us-west-2 = module.appsync_us_west_2.0.api_id
  })

  regional_appsync_endpoints = jsonencode({
    #us-east-1 = local.appsync_custom_url
    us-east-1 = format("https://%s/graphql", lookup(local.regional_apis["domains"], "us-east-1", ""))
    us-east-2 = format("https://%s/graphql", lookup(local.regional_apis["domains"], "us-east-2", ""))
    us-west-1 = format("https://%s/graphql", lookup(local.regional_apis["domains"], "us-west-1", ""))
    us-west-2 = format("https://%s/graphql", lookup(local.regional_apis["domains"], "us-west-2", ""))
  })

  app_user_pool_ids = jsonencode(
    {
      us-east-1 = module.app_cognito_pool_us_east_1.0.userpool_id
      us-east-2 = module.app_cognito_pool_us_east_2.0.userpool_id
      us-west-1 = module.app_cognito_pool_us_west_1.0.userpool_id
      us-west-2 = module.app_cognito_pool_us_west_2.0.userpool_id
    }
  )

  app_user_pool_client_ids = jsonencode(
    {
      us-east-1 = module.app_cognito_pool_us_east_1.0.client_id
      us-east-2 = module.app_cognito_pool_us_east_2.0.client_id
      us-west-1 = module.app_cognito_pool_us_west_1.0.client_id
      us-west-2 = module.app_cognito_pool_us_west_2.0.client_id
    }
  )
}

module "appsync_datasource" {
  description           = "The main datasource for the echo-stream API "
  dead_letter_arn       = local.lambda_dead_letter_arn
  environment_variables = local.appsync_datasource_lambda_environment_variables
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  memory_size           = 1536
  name                  = "${var.resource_prefix}-appsync-datasource"

  policy_arns = [
    data.aws_iam_policy.administrator_access.arn
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "4.0.1"
}