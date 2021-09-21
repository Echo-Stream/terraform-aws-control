##########################
##  Deployment handler  ##
##########################
data "aws_iam_policy_document" "deployment_handler" {

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
    ]

    resources = [
      "arn:aws:ecr:${local.current_region}:${local.artifacts_account_id}:repository/*"
    ]

    sid = "AppCognitoPoolAccess"
  }

  statement {
    actions = [
      "iam:CreateRole",
      "iam:PassRole",
    ]

    resources = ["*"]

    sid = "IAMPermissions"
  }
  statement {
    actions = [
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
      "lambda:PublishLayerVersion",
      "lambda:PublishVersion",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaDeployAccess"
  }

  statement {
    actions = [
      "appsync:StartSchemaCreation",
      "appsync:GetSchemaCreationStatus",
      "appsync:*GraphqlApi",
    ]

    resources = [
      "*"
    ]

    sid = "UpdateSchema"
  }

  statement {
    actions = [
      "sns:Subscribe"
    ]

    resources = [
      local.artifacts_sns_arn
    ]

    sid = "RegionalArtifactsSNSTopicSubscription"
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2",
    ]

    sid = "ListArtifactsBucket"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${var.echostream_version}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${var.echostream_version}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${var.echostream_version}/*",

    ]

    sid = "GetArtifacts"
  }

  statement {
    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = [
      aws_cloudfront_distribution.webapp.arn
    ]

    sid = "InvalidateWebappObjects"
  }

  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]

    resources = [
      module.graph_table.arn
    ]

    sid = "GraphTableUpdatePermissions"
  }
  statement {
    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.ci_cd_errors.arn
    ]

    sid = "snsPublish"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:PutRetentionPolicy"
    ]

    resources = [
      "*",
    ]

    sid = "AllowWritingErrorEvents"
  }
}


resource "aws_iam_policy" "deployment_handler" {
  description = "IAM permissions required for deployment-handler lambda"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-deployment-handler"
  policy      = data.aws_iam_policy_document.deployment_handler.json
}

module "deployment_handler" {
  description           = "Does appropriate deployments by getting notified from Artifacts bucket"
  environment_variables = local.common_lambda_environment_variables
  dead_letter_arn       = local.lambda_dead_letter_arn
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  memory_size           = 256
  name                  = "${var.resource_prefix}-deployment-handler"

  policy_arns = [
    aws_iam_policy.deployment_handler.arn,
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["deployment_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 600
  version       = "3.0.14"
}

resource "aws_sns_topic" "ci_cd_errors" {
  name         = "${var.resource_prefix}-ci-cd-errors"
  display_name = "${var.resource_prefix} CI/CD Notifications"
  tags         = local.tags
}

resource "aws_lambda_permission" "deployment_handler" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.deployment_handler.name
  principal     = "sns.amazonaws.com"
  source_arn    = local.artifacts_sns_arn
}

resource "aws_sns_topic_subscription" "artifacts" {
  topic_arn = local.artifacts_sns_arn
  protocol  = "lambda"
  endpoint  = module.deployment_handler.arn
}

#############################
##  Rebuild Notifications  ##
#############################
data "aws_iam_policy_document" "rebuild_notifications" {
  statement {
    actions = [
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
      "lambda:PublishLayerVersion",
      "lambda:PublishVersion",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaDeployAccess"
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2",
    ]

    sid = "ListArtifactsBucket"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${var.echostream_version}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${var.echostream_version}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${var.echostream_version}/*",

    ]

    sid = "GetArtifacts"
  }

  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage*",
      "sqs:DeleteMessage*",
      "sqs:GetQueueAttributes"
    ]

    resources = [aws_sqs_queue.rebuild_notifications.arn]

    sid = "EdgeQueuesAccess"
  }
}


resource "aws_iam_policy" "rebuild_notifications" {
  description = "IAM permissions required for deployment-handler lambda"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-rebuild-notifications"
  policy      = data.aws_iam_policy_document.deployment_handler.json
}

module "rebuild_notifications" {
  description           = "Rebuilds"
  environment_variables = local.common_lambda_environment_variables
  dead_letter_arn       = local.lambda_dead_letter_arn
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  memory_size           = 256
  name                  = "${var.resource_prefix}-rebuild-notifications"

  policy_arns = [
    aws_iam_policy.rebuild_notifications.arn,
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["rebuild_notifications"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 600
  version       = "3.0.14"
}

resource "aws_sqs_queue" "rebuild_notifications" {
  content_based_deduplication = "true"
  fifo_queue                  = true
  name                        = "${var.resource_prefix}-rebuild-notifications.fifo"
  tags                        = local.tags
  visibility_timeout_seconds  = 3600
}

resource "aws_iam_role" "rebuild_notifications_state_machine" {
  assume_role_policy = data.aws_iam_policy_document.state_machine_assume_role.json
  name               = "${var.resource_prefix}-rebuild-notifications-state-machine"
  tags               = local.tags
}

data "template_file" "rebuild_notifications_state_machine" {
  template = file("${path.module}/files/rebuild-notifications-state-machine.json")

  vars = {
    function_arn = module.rebuild_notifications.arn
    queue_url   = aws_sqs_queue.rebuild_notifications.url
  }
}

data "aws_iam_policy_document" "rebuild_notifications_state_machine" {
  statement {

    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [module.rebuild_notifications.arn]
    sid       = "InvokeLambda"
  }
}

resource "aws_iam_role_policy" "rebuild_notifications_state_machine" {
  policy = data.aws_iam_policy_document.rebuild_notifications_state_machine.json
  role   = aws_iam_role.rebuild_notifications_state_machine.id
}

resource "aws_sfn_state_machine" "rebuild_notifications" {
  definition = data.template_file.rebuild_notifications_state_machine.rendered
  name       = "${var.resource_prefix}-rebuild-notifications"
  role_arn   = aws_iam_role.rebuild_notifications_state_machine.arn
  tags       = local.tags
}