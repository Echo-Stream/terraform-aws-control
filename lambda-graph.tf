##################################
## graph-table-dynamodb-trigger ##
##################################
data "aws_iam_policy_document" "graph_table_dynamodb_trigger" {
  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      "arn:aws:sqs:*:${local.current_account_id}:db-stream*",
      aws_sqs_queue.system_sqs_queue.arn
    ]

    sid = "DeliverMessageToQueues"
  }

  statement {
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams",
    ]

    resources = [
      module.graph_table.stream_arn,
    ]

    sid = "AllowReadingFromStreams"
  }
}

resource "aws_iam_policy" "graph_table_dynamodb_trigger" {
  description = "IAM permissions required for graph-table-dynamodb-trigger"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-graph-table-dynamodb-trigger"
  policy      = data.aws_iam_policy_document.graph_table_dynamodb_trigger.json
}

module "graph_table_dynamodb_trigger" {
  dead_letter_arn       = local.lambda_dead_letter_arn
  description           = "Routes Dynamodb Stream events to the correct Lambda Functions"
  environment_variables = local.common_lambda_environment_variables
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  memory_size           = 1536
  name                  = "${var.resource_prefix}-graph-table-dynamodb-trigger"

  policy_arns = [
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.graph_ddb_write.arn,
    aws_iam_policy.graph_table_dynamodb_trigger.arn,
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_dynamodb_trigger"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.18"
}

resource "aws_lambda_event_source_mapping" "graph_table_dynamodb_trigger" {
  batch_size        = "1"
  event_source_arn  = module.graph_table.stream_arn
  function_name     = module.graph_table_dynamodb_trigger.name
  starting_position = "LATEST"
}

resource "aws_iam_role" "managed_app" {
  description        = "Enable AWS Systems Manager service core functionality"
  name               = "${var.resource_prefix}-managed-app"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.managed_app.json
  tags               = local.tags
}

data "aws_iam_policy_document" "managed_app" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "ssm.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "managed_app_customer_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*"
    ]

    sid = "LogsAccess"
  }

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = [aws_sns_topic.managed_app_cloud_init.arn]

    sid = "PublishToSNS"
  }
}

resource "aws_iam_policy" "managed_app_customer_policy" {
  description = "IAM permissions required for manage apps ssm"
  path        = "/lambda/control/"
  policy      = data.aws_iam_policy_document.managed_app_customer_policy.json
}

resource "aws_iam_role_policy_attachment" "managed_app_customer_policy" {
  policy_arn = aws_iam_policy.managed_app_customer_policy.arn
  role       = aws_iam_role.managed_app.name
}

resource "aws_iam_role_policy_attachment" "managed_app_ecr_read" {
  policy_arn = aws_iam_policy.ecr_read.arn
  role       = aws_iam_role.managed_app.name
}

resource "aws_iam_role_policy_attachment" "managed_app" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.managed_app.name
}

resource "aws_iam_role_policy_attachment" "manage_apps_ssm_directory_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
  role       = aws_iam_role.managed_app.name
}

#######################################
## graph-table-tenant-stream-handler ##
#######################################
data "aws_iam_policy_document" "graph_table_tenant_stream_handler" {
  statement {
    actions = [
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable",
      "dynamodb:UpdateTimeToLive",
    ]

    resources = [
      "arn:aws:dynamodb:*:${local.current_account_id}:table/${var.resource_prefix}-tenant-*"
    ]

    sid = "DeleteTenantTables"
  }

  statement {
    actions = [
      "firehose:DeleteDeliveryStream",
      "firehose:PutRecord*",
    ]

    resources = [
      "arn:aws:firehose:*:${local.current_account_id}:deliverystream/${var.resource_prefix}-tenant-*"
    ]

    sid = "FirehosePermissions"
  }

  statement {
    actions = [
      "dynamodb:DeleteItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "DeleteItem"
  }

  statement {
    actions = [
      "logs:DeleteLogStream"
    ]

    resources = [
      "arn:aws:logs:*:${local.current_account_id}:log-group:/aws/kinesisfirehose/${var.resource_prefix}-audit-firehose:log-stream:*"
    ]

    sid = "DeleteLogStream"
  }
}

resource "aws_iam_policy" "graph_table_tenant_stream_handler" {
  description = "IAM permissions required for graph-table-tenant-stream-handler"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-graph-table-tenant-stream-handler"
  policy      = data.aws_iam_policy_document.graph_table_tenant_stream_handler.json
}

module "graph_table_tenant_stream_handler" {
  description     = "Delegates calls to handling lambda functions in EchoStream Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = merge(local.common_lambda_environment_variables,
  { LOGGING_LEVEL = "DEBUG" })

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.resource_prefix}-graph-table-tenant-stream-handler"

  policy_arns = [
    aws_iam_policy.ecr_read.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.graph_ddb_write.arn,
    aws_iam_policy.graph_table_tenant_stream_handler.arn,
    aws_iam_policy.graph_table_handler.arn,
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_tenant_stream_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 900
  version       = "3.0.15"
}

#######################################
## graph-table-system-stream-handler ##
#######################################
data "aws_iam_policy_document" "graph_table_system_stream_handler" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "DeleteItem"
  }
}

resource "aws_iam_policy" "graph_table_system_stream_handler" {
  description = "IAM permissions required for graph-table-system-stream-handler"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-graph-table-system-stream-handler"
  policy      = data.aws_iam_policy_document.graph_table_system_stream_handler.json
}

module "graph_table_system_stream_handler" {
  description     = "Handles system-related DB changes"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = merge(local.common_lambda_environment_variables,
  { LOGGING_LEVEL = "DEBUG" })

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.resource_prefix}-graph-table-system-stream-handler"

  policy_arns = [
    aws_iam_policy.ecr_read.arn,
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.graph_ddb_write.arn,
    aws_iam_policy.graph_table_handler.arn,
    aws_iam_policy.graph_table_system_stream_handler.arn,
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_system_stream_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 900
  version       = "3.0.18"
}

resource "aws_lambda_event_source_mapping" "graph_table_system_stream_handler" {
  function_name    = module.graph_table_system_stream_handler.arn
  event_source_arn = aws_sqs_queue.system_sqs_queue.arn
}