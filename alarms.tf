resource "aws_cloudwatch_metric_alarm" "appsync_app_ds_lambda" {
  alarm_name          = "${var.environment_prefix}-appsync-app-ds-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "true"
  dimensions = {
    FunctionName = module.appsync_app_datasource.name
  }
  alarm_actions     = [aws_sns_topic.alerts.arn]
  ok_actions        = [aws_sns_topic.alerts.arn]
  alarm_description = "This metric monitors lambda errors"
}