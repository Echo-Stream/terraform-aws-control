module "alarms" {
  lambdas = {
    appsync_kms_key_datasource       = module.appsync_kms_key_datasource.name
    appsync_tenant_datasource        = module.appsync_tenant_datasource.name
    app_cognito_pre_authentication   = module.app_cognito_pre_authentication.name
    app_cognito_pre_token_generation = module.app_cognito_pre_token_generation.name

  }
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
  tags          = local.tags
  source        = "./_modules/lambda-alarms"
}