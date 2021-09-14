resource "aws_cloudwatch_event_rule" "alarm_distribution" {
  name        = var.name
  description = "CloudWatch Alarm State Change"

  event_pattern = <<EOF
{
  "detail-type": [
    "CloudWatch Alarm State Change"
  ],
    "source": [
    "aws.cloudwatch"
  ],
    "account": [
    "${var.account_id}"
  ]
}
EOF

  tags     = var.tags
}

resource "aws_cloudwatch_event_target" "alarm_distribution" {
  rule      = aws_cloudwatch_event_rule.alarm_distribution.name
  target_id = "SendToSNS"
  arn       = var.alarm_sns_topic_arn
}