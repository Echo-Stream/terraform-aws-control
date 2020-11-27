module "alarms" {
  lambdas = {
    appsync_kms_key_datasource = module.appsync_kms_key_datasource.name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
  source        = "./_modules/lambda-alarms"
}