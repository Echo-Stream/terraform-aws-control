resource "aws_sns_topic" "alarms" {
  name         = "${var.resource_prefix}-alarms"
  display_name = "${var.resource_prefix} Alarms"
  tags         = local.tags
}

resource "aws_sns_topic_subscription" "alarms" {
  endpoint  = var.support_email
  protocol  = "email"
  topic_arn = aws_sns_topic.alarms.arn
}

resource "aws_cloudwatch_metric_alarm" "lambda" {
  alarm_actions       = [aws_sns_topic.alarms.arn]
  alarm_description   = "Errors > 1 for ${aws_lambda_function.appsync_datasource.function_name}"
  alarm_name          = "lambda:${aws_lambda_function.appsync_datasource.function_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = aws_lambda_function.appsync_datasource.function_name
  }

  evaluation_periods = "1"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  ok_actions         = [aws_sns_topic.alarms.arn]
  period             = "60"
  statistic          = "Sum"
  threshold          = "1"
  treat_missing_data = "notBreaching"
  unit               = "Count"

  tags = var.tags
}
