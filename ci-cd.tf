##########################
##  Deployment handler  ##
##########################
data "aws_iam_policy_document" "deployment_handler" {
  statement {
    actions = [
      "lambda:PublishLayerVersion",
      "lambda:PublishVersion",
      "lambda:UpdateFunctionCode",
      "lambda:ListFunctions",
      "lambda:GetFunction",
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
}

resource "aws_iam_policy" "deployment_handler" {
  description = "IAM permissions required for deployment-handler lambda"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-deployment-handler"
  policy      = data.aws_iam_policy_document.deployment_handler.json
}

module "deployment_handler" {
  description = "Does appropriate deployments by getting notified from Artifacts bucket"

  environment_variables = {
    API_ID                     = aws_appsync_graphql_api.echostream.id
    ARTIFACTS_BUCKET           = local.artifacts_bucket
    CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.webapp.id
    CONTROL_REGION             = local.current_region
    DEFAULT_TENANT_NAME        = "DEFAULT_TENANT"
    DYNAMODB_TABLE             = module.graph_table.name
    ECHOSTREAM_VERSION         = var.echostream_version
    ENVIRONMENT                = var.resource_prefix
    REGION                     = var.region
    SNS_TOPIC_ARN              = aws_sns_topic.ci_cd_errors.arn
    system_sqs_queue_URL       = aws_sqs_queue.system_sqs_queue.id
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 256
  name            = "${var.resource_prefix}-deployment-handler"

  policy_arns = [
    aws_iam_policy.deployment_handler.arn,
  ]

  runtime       = "python3.8"
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