locals {

  sqs_names = [
    aws_sqs_queue.system_sqs_queue.name,
    aws_sqs_queue.managed_app_cloud_init.name,
    aws_sqs_queue.rebuild_notifications.name
  ]

  lambda_names = [
    module.api_cognito_pre_authentication.name,
    module.appsync_datasource_lambda.name,
    module.deployment_handler.name,
    module.graph_table_dynamodb_trigger.name,
    module.graph_table_system_stream_handler.name,
    module.graph_table_tenant_stream_handler.name,
    module.managed_app_cloud_init.name,
    module.rebuild_notifications.name,
    module.ui_cognito_post_confirmation.name,
    module.ui_cognito_pre_authentication.name,
    module.ui_cognito_pre_signup.name,
  ]

}


resource "aws_cloudwatch_metric_alarm" "sqs" {
  for_each = toset(local.sqs_names)

  alarm_actions       = [aws_sns_topic.alarms.arn]
  alarm_description   = "Age of oldest message >= 120 for ${each.key}"
  alarm_name          = "sqs:${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    QueueName = each.key
  }

  evaluation_periods = "1"
  metric_name        = "ApproximateAgeOfOldestMessage"
  namespace          = "AWS/SQS"
  ok_actions         = [aws_sns_topic.alarms.arn]
  period             = "60"
  statistic          = "Maximum"
  threshold          = "120"
  treat_missing_data = "notBreaching"
  unit               = "Seconds"

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda" {
  for_each = toset(local.lambda_names)

  alarm_actions       = [aws_sns_topic.alarms.arn]
  alarm_description   = "Errors > 1 for ${each.key}"
  alarm_name          = "lambda:${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = each.key
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

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "stepfunction" {
  alarm_actions       = [aws_sns_topic.alarms.arn]
  alarm_description   = "ExecutionsFailed > 1 for ${aws_sfn_state_machine.rebuild_notifications.name} state machine"
  alarm_name          = "state-machine:${aws_sfn_state_machine.rebuild_notifications.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    StateMachineArn = aws_sfn_state_machine.rebuild_notifications.arn
  }

  evaluation_periods = "1"
  metric_name        = "ExecutionsFailed"
  namespace          = "AWS/States"
  ok_actions         = [aws_sns_topic.alarms.arn]
  period             = "60"
  statistic          = "Sum"
  threshold          = "1"
  treat_missing_data = "notBreaching"
  unit               = "Count"

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "replication" {
  for_each = setsubtract(var.tenant_regions, [data.aws_region.current.name])

  alarm_actions       = [aws_sns_topic.alarms.arn]
  alarm_description   = "Replication >= 2000ms for ${each.key}"
  alarm_name          = "replication:${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    ReceivingRegion = each.key
    TableName       = module.graph_table.name
  }

  evaluation_periods = "1"
  metric_name        = "ReplicationLatency"
  namespace          = "AWS/DynamoDB"
  ok_actions         = [aws_sns_topic.alarms.arn]
  period             = "60"
  statistic          = "Maximum"
  threshold          = "2000"
  treat_missing_data = "notBreaching"
  unit               = "Milliseconds"

  tags = local.tags
}
