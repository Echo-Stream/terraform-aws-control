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
      "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:echostream-artifacts-${local.current_region}"
    ]

    sid = "RegionalArtifactsSNSTopicSubscription"
  }

  statement {
    actions = [
      "s3:GetObject*",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::echostream-artifacts-${local.current_region}",
      "arn:aws:s3:::echostream-artifacts-${local.current_region}/*"
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
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-deployment-handler"
  policy      = data.aws_iam_policy_document.deployment_handler.json
}

module "deployment_handler" {
  description = "Does appropriate deployments by getting notified from Artifacts bucket"

  environment_variables = {
    API_ID                     = aws_appsync_graphql_api.echostream.id
    ARTIFACTS_BUCKET           = local.artifacts_bucket
    CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.webapp.id
    DYNAMODB_TABLE             = module.graph_table.name
    ECHOSTREAM_VERSION         = var.echostream_version
    ENVIRONMENT                = var.environment_prefix
    SNS_TOPIC_ARN              = aws_sns_topic.ci_cd_errors.arn
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-deployment-handler"

  policy_arns = [
    aws_iam_policy.deployment_handler.arn,
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["deployment_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.11"
}

resource "aws_sns_topic" "ci_cd_errors" {
  name         = "${var.environment_prefix}-ci-cd-errors"
  display_name = "${var.environment_prefix} CI/CD Notifications"
  tags         = local.tags
}

resource "aws_lambda_permission" "deployment_handler" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.deployment_handler.name
  principal     = "sns.amazonaws.com"
  source_arn    = "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:echostream-artifacts-${local.current_region}"
}

resource "aws_sns_topic_subscription" "artifacts" {
  topic_arn = "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:echostream-artifacts-${local.current_region}"
  protocol  = "lambda"
  endpoint  = module.deployment_handler.arn
}