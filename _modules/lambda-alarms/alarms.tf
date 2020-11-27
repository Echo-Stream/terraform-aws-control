resource "aws_cloudwatch_metric_alarm" "lambda" {
  for_each = var.lambdas
  alarm_name          = "lambda/errors/${each.value}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "true"
  dimensions = {
    FunctionName = each.value
  }
  alarm_actions     = [aws_sns_topic.alerts.arn]
  ok_actions        = [aws_sns_topic.alerts.arn]
  alarm_description = "This metric monitors lambda errors"
  tags              = var.tags
}