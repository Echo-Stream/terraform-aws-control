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
      "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:db-stream*",
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

  name   = "${var.resource_prefix}-graph-table-dynamodb-trigger"
  policy = data.aws_iam_policy_document.graph_table_dynamodb_trigger.json
}

module "graph_table_dynamodb_trigger" {
  dead_letter_arn       = local.lambda_dead_letter_arn
  description           = "Routes Dynamodb Stream events to the correct Lambda Functions"
  environment_variables = local.common_lambda_environment_variables
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  layers                = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size           = 1536
  name                  = "${var.resource_prefix}-graph-table-dynamodb-trigger"

  policy_arns = [
    aws_iam_policy.graph_ddb_read.arn,
    aws_iam_policy.graph_table_dynamodb_trigger.arn,
    aws_iam_policy.read_lambda_environment.arn,
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_dynamodb_trigger"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "4.0.2"
}

resource "aws_lambda_event_source_mapping" "graph_table_dynamodb_trigger" {
  batch_size              = "1"
  event_source_arn        = module.graph_table.stream_arn
  function_name           = module.graph_table_dynamodb_trigger.name
  function_response_types = ["ReportBatchItemFailures"]
  starting_position       = "LATEST"
}

resource "aws_iam_role" "managed_app" {
  description        = "Enable AWS Systems Manager service core functionality"
  name               = "${var.resource_prefix}-managed-app"
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
    effect = "Allow"

    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]

    resources = [aws_sqs_queue.managed_app_cloud_init.arn]

    sid = "SendMessageToManagedAppCloudInitQueue"
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/echostream/managed-app/*"
    ]

    sid = "Logs"
  }
}

resource "aws_iam_policy" "managed_app_customer_policy" {
  description = "IAM permissions required for manage apps ssm"
  name        = "${var.resource_prefix}-managed-app-customer"
  policy      = data.aws_iam_policy_document.managed_app_customer_policy.json
}

resource "aws_iam_role_policy_attachment" "manage_apps_ecr_read_access" {
  policy_arn = aws_iam_policy.ecr_read.arn
  role       = aws_iam_role.managed_app.name
}

resource "aws_iam_role_policy_attachment" "manage_apps_ssm_directory_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
  role       = aws_iam_role.managed_app.name
}

resource "aws_iam_role_policy_attachment" "managed_app" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.managed_app.name
}

resource "aws_iam_role_policy_attachment" "managed_app_customer_policy" {
  policy_arn = aws_iam_policy.managed_app_customer_policy.arn
  role       = aws_iam_role.managed_app.name
}

resource "aws_iam_role_policy_attachment" "managed_app_ecr_read" {
  policy_arn = aws_iam_policy.ecr_read.arn
  role       = aws_iam_role.managed_app.name
}

module "graph_table_tenant_stream_handler" {
  description     = "Delegates calls to handling lambda functions in EchoStream Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = local.common_lambda_environment_variables

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  layers      = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size = 1536
  name        = "${var.resource_prefix}-graph-table-tenant-stream-handler"

  policy_arns = [
    data.aws_iam_policy.administrator_access.arn
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_tenant_stream_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 900
  version       = "4.0.2"
}

module "graph_table_system_stream_handler" {
  description     = "Handles system-related DB changes"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = local.common_lambda_environment_variables

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  layers      = [local.echocore_layer_version_arns[data.aws_region.current.name]]
  memory_size = 1536
  name        = "${var.resource_prefix}-graph-table-system-stream-handler"

  policy_arns = [
    data.aws_iam_policy.administrator_access.arn
  ]

  runtime       = local.lambda_runtime
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_system_stream_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 900
  version       = "4.0.2"
}

resource "aws_lambda_event_source_mapping" "graph_table_system_stream_handler" {
  event_source_arn        = aws_sqs_queue.system_sqs_queue.arn
  function_name           = module.graph_table_system_stream_handler.arn
  function_response_types = ["ReportBatchItemFailures"]
}
