locals {

  sqs_names = [
    aws_sqs_queue.system_sqs_queue.name,
    aws_sqs_queue.managed_app_cloud_init.name,
    aws_sqs_queue.rebuild_notifications.name
  ]

}


resource "aws_cloudwatch_metric_alarm" "sqs" {
  for_each = toset(local.sqs_names)

  alarm_name          = each.key
  alarm_actions       = [aws_sns_topic.alarms.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    QueueName = each.key
  }

  evaluation_periods        = "4"
  metric_name               = "ApproximateAgeOfOldestMessage"
  namespace                 = "AWS/SQS"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "120"
  alarm_description         = "Age of oldest message >= 120"
  insufficient_data_actions = [aws_sns_topic.alarms.arn]
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda" {

  alarm_name          = "test"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = module.appsync_datasource.name
  }

  evaluation_periods        = "4"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "120"
  alarm_description         = "Errors > 1"
  insufficient_data_actions = [aws_sns_topic.alarms.arn]
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = local.tags
}
