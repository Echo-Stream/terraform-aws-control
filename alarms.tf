resource "aws_cloudwatch_metric_alarm" "lambda" {
  alarm_name          = "${var.environment_prefix}-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  dimensions          = "none"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  alarm_description   = "This metric monitors lambda errors"
}