locals {

}
resource "aws_sqs_queue" "system_sqs_queue" {
  content_based_deduplication = "true"
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
  name                        = "${var.resource_prefix}-system-db-stream.fifo"
  visibility_timeout_seconds  = 900

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "system_sqs_queue" {
  alarm_name          = "terraform-test-foobar5"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  dimensions = {
    QueueName = aws_sqs_queue.system_sqs_queue.name
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

  tags = local.tags
}

resource "aws_sqs_queue" "stream_dead_letter_queue" {
  content_based_deduplication = "true"
  fifo_queue                  = true
  name                        = "${var.resource_prefix}-stream-dead-letter.fifo"

  tags = local.tags
}

resource "aws_sqs_queue" "managed_app_cloud_init" {
  content_based_deduplication = "true"
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
  name                        = "${var.resource_prefix}-managed-app-cloud-init.fifo"
  visibility_timeout_seconds  = 900

  tags = local.tags
}