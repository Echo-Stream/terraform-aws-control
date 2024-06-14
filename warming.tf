resource "aws_cloudwatch_event_rule" "warming" {
  name                = "${var.resource_prefix}-warming"
  description         = "Sends warming message every 12 minutes"
  schedule_expression = "rate(12 minutes)"
  tags                = local.tags
}

resource "aws_sns_topic" "warming" {
  name         = "${var.resource_prefix}-warming"
  display_name = "${var.resource_prefix} Warming"
  tags         = local.tags
}

data "aws_iam_policy_document" "warming" {
  statement {
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
      "sns:Receive",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]

    }
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [aws_sns_topic.warming.arn]
    sid       = "OwnerAccess"
  }
  statement {
    actions = ["sns:Publish"]
    sid     = "AWSEvents"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    resources = [aws_sns_topic.warming.arn]
  }
}

resource "aws_sns_topic_policy" "warming" {
  arn    = aws_sns_topic.warming.arn
  policy = data.aws_iam_policy_document.warming.json
}

resource "aws_cloudwatch_event_target" "warming" {
  arn       = aws_sns_topic.warming.arn
  input     = "\"warmup\""
  rule      = aws_cloudwatch_event_rule.warming.name
  target_id = "${var.resource_prefix}-warming"
}

resource "aws_lambda_permission" "warming" {
  for_each = toset(
    concat(
      [
        module.appsync_datasource.name,
        module.graph_table_dynamodb_trigger.name,
        module.graph_table_system_stream_handler.name,
        module.graph_table_tenant_stream_handler.name,
      ],
      var.billing_enabled ? [module.paddle_webhooks[0].name] : []
    )
  )
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.warming.arn
}

resource "aws_sns_topic_subscription" "warming_appsync_datasource" {
  topic_arn = aws_sns_topic.warming.arn
  protocol  = "lambda"
  endpoint  = module.appsync_datasource.arn
}

resource "aws_sns_topic_subscription" "warming_graph_table_dynamodb_trigger" {
  topic_arn = aws_sns_topic.warming.arn
  protocol  = "lambda"
  endpoint  = module.graph_table_dynamodb_trigger.arn
}

resource "aws_sns_topic_subscription" "warming_graph_table_system_stream_handler" {
  topic_arn = aws_sns_topic.warming.arn
  protocol  = "lambda"
  endpoint  = module.graph_table_system_stream_handler.arn
}

resource "aws_sns_topic_subscription" "warming_graph_table_tenant_stream_handler" {
  topic_arn = aws_sns_topic.warming.arn
  protocol  = "lambda"
  endpoint  = module.graph_table_tenant_stream_handler.arn
}

resource "aws_sns_topic_subscription" "warming_paddle_webhooks" {
  count     = var.billing_enabled ? 1 : 0
  topic_arn = aws_sns_topic.warming.arn
  protocol  = "lambda"
  endpoint  = module.paddle_webhooks[0].arn
}
