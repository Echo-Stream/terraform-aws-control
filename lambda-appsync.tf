## Internal Fn IAM assume role
resource "aws_iam_role" "tenant_function_role" {
  name               = "${var.environment_prefix}-tenant-functions"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "tenant_function_logging" {
  role       = aws_iam_role.tenant_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "tenant_function_role" {
  statement {
    effect = "Allow"

    actions = [
      "firehose:PutRecord*"
    ]

    resources = [aws_kinesis_firehose_delivery_stream.process_audit_record_firehose.arn]

    sid = "WriteToFirehose"
  }
}

resource "aws_iam_policy" "tenant_function" {
  description = "IAM permissions required for tenant functions"
  path        = "/${var.environment_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.tenant_function_role.json
}

resource "aws_iam_role_policy_attachment" "tenant_function_role" {
  role       = aws_iam_role.tenant_function_role.name
  policy_arn = aws_iam_policy.tenant_function.arn
}

## additional-ddb-policy ##
data "aws_iam_policy_document" "additional_ddb_policy" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Query"
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*"
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "additional_ddb_policy" {
  description = "IAM permissions to read graph-table-dynamodb-trigger"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-additional-ddb-policy"
  policy      = data.aws_iam_policy_document.additional_ddb_policy.json
}

##################################
##  appsync-kms-key-datasource  ##
##################################
data "aws_iam_policy_document" "appsync_kms_key_datasource" {
  statement {
    actions = [
      "kms:CreateKey",
      "kms:DescribeKey",
      "kms:TagResource"
    ]

    resources = ["*"]

    sid = "KMSPermissions"
  }
}

resource "aws_iam_policy" "appsync_kms_key_datasource" {
  description = "IAM permissions required for appsync-kms-key-datasource lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-kms-key-datasource"
  policy      = data.aws_iam_policy_document.appsync_kms_key_datasource.json
}

module "appsync_kms_key_datasource" {
  description     = "Manages SQS/KMS resource and IAM policies from a Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn
  environment_variables = {

    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
    LOG_LEVEL      = "INFO"

  }
  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.environment_prefix}-appsync-kms-key-datasource"

  policy_arns = [
    aws_iam_policy.appsync_kms_key_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_kms_key_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

##################################
##  appsync-tenant-datasource   ##
##################################
data "aws_iam_policy_document" "appsync_tenant_datasource" {
  statement {
    actions = [
      "kms:CreateKey",
      "kms:TagKey",
      "kms:TagResource",
    ]

    resources = ["*"]

    sid = "KMSPermissions"
  }

  statement {
    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:TagQueue",
      "sqs:ListQueues",
      "sqs:GetQueueAttributes",
    ]

    resources = [
      "arn:aws:sqs:*:*:*_db-stream_*"
    ]

    sid = "SQSPermissions"
  }

  statement {
    actions = [
      "lambda:CreateEventSourceMapping",
      "lambda:GetEventSourceMapping",
      "lambda:ListEventSourceMappings",
    ]

    resources = [
      "*"
    ]

    condition {
      test = "StringEquals"

      values = [
        module.graph_table_tenant_stream_handler.arn
      ]

      variable = "lambda:FunctionArn"
    }

    sid = "LambdaEventSourceMappings"
  }

  statement {
    actions = [
      "dynamodb:Query",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:PutItem",
    ]

    resources = [
      "${module.graph_table.arn}/*",
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::hl7-ninja-artifacts-${local.current_region}/${local.artifacts["message_types"]}/*"
    ]

    sid = "GetMessageTypesArtifacts"
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::hl7-ninja-artifacts-${local.current_region}"
    ]

    sid = "ListArtifactsS3"
  }
}

resource "aws_iam_policy" "appsync_tenant_datasource" {
  description = "IAM permissions required for appsync-tenant-datasource lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-tenant-datasource"
  policy      = data.aws_iam_policy_document.appsync_tenant_datasource.json
}

module "appsync_tenant_datasource" {
  description     = "Creates/removes tenants and their AWS resources"
  dead_letter_arn = local.lambda_dead_letter_arn
  environment_variables = {
    DYNAMODB_TABLE          = module.graph_table.name
    ENVIRONMENT             = var.environment_prefix
    LOG_LEVEL               = "INFO"
    ARTIFACTS_BUCKET        = local.artifacts_bucket
    APP_VERSION             = var.hl7_ninja_version
    STREAM_HANDLER_FUNCTION = module.graph_table_tenant_stream_handler.arn
  }
  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.environment_prefix}-appsync-tenant-datasource"

  policy_arns = [
    aws_iam_policy.appsync_tenant_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_tenant_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

# ################################
# ##     ninja_tools_layer      ##
# ################################
# resource "aws_lambda_layer_version" "ninja_tools" {
#   s3_bucket  = local.artifacts_bucket
#   s3_key     = local.lambda_functions_keys["ninja_tools_layer"]
#   layer_name = "ninja-tools-layer"
# }

######################################
##  app-cognito-pre-authentication  ##
######################################
data "aws_iam_policy_document" "app_cognito_pre_authentication" {
  statement {
    actions = [
      "dynamodb:Query",
    ]

    resources = [
      "${module.graph_table.arn}/*",
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "app_cognito_pre_authentication" {
  description = "IAM permissions required for app-cognito-pre-authentication lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-app-cognito-pre-authentication"
  policy      = data.aws_iam_policy_document.app_cognito_pre_authentication.json
}

module "app_cognito_pre_authentication" {
  description = "Function that gets triggered when cognito user to be authenticated"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
    INDEX_NAME     = "gsi0"
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-app-cognito-pre-authentication"

  policy_arns = [
    aws_iam_policy.app_cognito_pre_authentication.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["app_cognito_pre_authentication"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

resource "aws_lambda_permission" "app_cognito_pre_authentication" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.app_cognito_pre_authentication.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.hl7_ninja_apps.arn
}

########################################
##  app-cognito-pre-token-generation  ##
########################################
data "aws_iam_policy_document" "app_cognito_pre_token_generation" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "app_cognito_pre_token_generation" {
  description = "IAM permissions required for app-cognito-pre-token-generation lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-app-cognito-pre-token-generation"
  policy      = data.aws_iam_policy_document.app_cognito_pre_token_generation.json
}

module "app_cognito_pre_token_generation" {
  description = "Customizes the claims in the identity token"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-app-cognito-pre-token-generation"

  policy_arns = [
    aws_iam_policy.app_cognito_pre_token_generation.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["app_cognito_pre_token_generation"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

resource "aws_lambda_permission" "app_cognito_pre_token_generation" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.app_cognito_pre_token_generation.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.hl7_ninja_apps.arn
}

###############################
##  appsync-edge-datasource  ##
###############################
data "aws_iam_policy_document" "appsync_edge_datasource" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "sqs:CreateQueue",
      "sqs:GetQueueUrl",
      "sqs:TagQueue",
      "sqs:DeleteQueue",
    ]

    resources = [
      "*"
    ]

    sid = "SQS"
  }

  statement {
    actions = [
      "kms:DescribeKey",
      "kms:ListAlias",
      "kms:ListKeys",
    ]

    resources = ["*"]

    sid = "KMSPermissions"
  }
}

resource "aws_iam_policy" "appsync_edge_datasource" {
  description = "IAM permissions required for appsync-edge-datasource lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-edge-datasource"
  policy      = data.aws_iam_policy_document.appsync_edge_datasource.json
}

module "appsync_edge_datasource" {
  description = "Appsync datasource for managing edges"

  environment_variables = {
    DYNAMODB_TABLE         = module.graph_table.name
    ENVIRONMENT            = var.environment_prefix
    LOG_LEVEL              = "INFO"
    MESSAGE_RETENTION_DAYS = 10
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-appsync-edge-datasource"

  policy_arns = [
    aws_iam_policy.appsync_edge_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_edge_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}


##############################
##  ui-cognito-post-signup  ##
##############################
data "aws_iam_policy_document" "ui_cognito_post_signup" {
  statement {
    actions = [
      "dynamodb:UpdateItem",
      "dynamodb:Query",
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/*",
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "ui_cognito_post_signup" {
  description = "IAM permissions required for ui-cognito-post-signup lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-ui-cognito-post-signup"
  policy      = data.aws_iam_policy_document.ui_cognito_post_signup.json
}

module "ui_cognito_post_signup" {
  description = "Set attributes on UI user and validate invitation token post signup "

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-ui-cognito-post-signup"

  policy_arns = [
    aws_iam_policy.ui_cognito_post_signup.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_post_signup"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

resource "aws_lambda_permission" "ui_cognito_post_signup" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_post_signup.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.hl7_ninja_ui.arn
}

#####################################
##  ui-cognito-pre-authentication  ##
#####################################
data "aws_iam_policy_document" "ui_cognito_pre_authentication" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem"

    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "ui_cognito_pre_authentication" {
  description = "IAM permissions required for ui-cognito-pre-authentication lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-ui-cognito-pre-authentication"
  policy      = data.aws_iam_policy_document.ui_cognito_pre_authentication.json
}

module "ui_cognito_pre_authentication" {
  description = "Check status and tenant membership pre authentication for UI users"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-ui-cognito-pre-authentication"

  policy_arns = [
    aws_iam_policy.ui_cognito_pre_authentication.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_pre_authentication"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

resource "aws_lambda_permission" "ui_cognito_pre_authentication" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_pre_authentication.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.hl7_ninja_ui.arn
}

#############################
##  ui-cognito-pre-signup  ##
#############################
data "aws_iam_policy_document" "ui_cognito_pre_signup" {
  statement {
    actions = [
      "dynamodb:UpdateItem",
      "dynamodb:PutItem"
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "ui_cognito_pre_signup" {
  description = "IAM permissions required for ui-cognito-pre-signup lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-ui-cognito-pre-signup"
  policy      = data.aws_iam_policy_document.ui_cognito_pre_signup.json
}

module "ui_cognito_pre_signup" {
  description = "Validate invitation for new UI user "

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-ui-cognito-pre-signup"

  policy_arns = [
    aws_iam_policy.ui_cognito_pre_signup.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_pre_signup"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

resource "aws_lambda_permission" "ui_cognito_pre_signup" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_pre_signup.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.hl7_ninja_ui.arn
}

#######################################
##  ui-cognito-pre-token-generation  ##
#######################################
data "aws_iam_policy_document" "ui_cognito_pre_token_generation" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "ui_cognito_pre_token_generation" {
  description = "IAM permissions required for ui-cognito-pre-token-generation lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-ui-cognito-pre-token-generation"
  policy      = data.aws_iam_policy_document.ui_cognito_pre_token_generation.json
}

module "ui_cognito_pre_token_generation" {
  description = "Add tenant claim to UI user"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-ui-cognito-pre-token-generation"

  policy_arns = [
    aws_iam_policy.ui_cognito_pre_token_generation.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["ui_cognito_pre_token_generation"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

resource "aws_lambda_permission" "ui_cognito_pre_token_generation" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.ui_cognito_pre_token_generation.name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.hl7_ninja_ui.arn
}

###########################
#  process-audit-record  ##
###########################
module "process_audit_record" {
  description = "Processes a message audit record as it passes through the firehose"

  environment_variables = {
    APP_CLIENT_ID   = aws_cognito_user_pool_client.hl7_ninja_apps_userpool_client.id
    ENVIRONMENT     = var.environment_prefix
    ID_TOKEN_KEY    = <<-EOT
                        {
                          "kty": "oct",
                          "kid": "${random_uuid.for_jwk.result}"
                          "use": "sig",
                          "alg": "HS256",
                          "k": "${base64encode(random_string.for_jwk.result)}"
                        }
                      EOT
    USERPOOL_ID     = aws_cognito_user_pool.hl7_ninja_apps.id
    USERPOOL_REGION = local.current_region
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-process-audit-record"
  runtime         = "python3.8"
  s3_bucket       = local.artifacts_bucket
  s3_object_key   = local.lambda_functions_keys["process_audit_record"]
  source          = "QuiNovas/lambda/aws"
  tags            = local.tags
  timeout         = 30
  version         = "3.0.10"
}

resource "random_uuid" "for_jwk" {}

resource "random_string" "for_jwk" {
  length  = 64
  special = true
}

#########################
##  validate-function  ##
#########################
module "validate_function" {
  description     = "Validates a python function that is passed in by running it and returning the results"
  dead_letter_arn = local.lambda_dead_letter_arn
  environment_variables = {
    ENVIRONMENT = var.environment_prefix
  }
  handler       = "function.handler"
  kms_key_arn   = local.lambda_env_vars_kms_key_arn
  memory_size   = 1536
  name          = "${var.environment_prefix}-validate-function"
  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["validate_function"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

#######################################
##  appsync-message-type-datasource  ##
#######################################
data "aws_iam_policy_document" "appsync_message_type_datasource" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:DeleteItem",
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*"
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "appsync_message_type_datasource" {
  description = "IAM permissions required for appsync-message-type-datasource lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-message-type-datasource"
  policy      = data.aws_iam_policy_document.appsync_message_type_datasource.json
}

module "appsync_message_type_datasource" {
  description = "AppSync datasource lambda function that handles putting of MessageTypes"

  environment_variables = {
    DYNAMODB_TABLE  = module.graph_table.name
    ENVIRONMENT     = var.environment_prefix
    LOG_LEVEL       = "INFO"
    ARTIFACT_BUCKET = local.artifacts_bucket
    APP_VERSION     = var.hl7_ninja_version
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-appsync-message-type-datasource"

  policy_arns = [
    aws_iam_policy.appsync_message_type_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_message_type_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

##########################
##  Deployment handler  ##
##########################
data "aws_iam_policy_document" "deployment_handler" {
  statement {
    actions = [
      "lambda:PublishLayerVersion",
      "lambda:PublishVersion",
      "lambda:UpdateFunctionCode",
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
      "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:hl7-ninja-artifacts-${local.current_region}"
    ]

    sid = "RegionalArtifactsSNSTopicSubscription"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::hl7-ninja-artifacts-${local.current_region}/*"
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
    HL7_NINJA_VERSION          = var.hl7_ninja_version
    ENVIRONMENT                = var.environment_prefix
    ARTIFACTS_BUCKET           = local.artifacts_bucket
    API_ID                     = aws_appsync_graphql_api.hl7_ninja.id
    CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.webapp.id
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
  version       = "3.0.10"
}

resource "aws_lambda_permission" "deployment_handler" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.deployment_handler.name
  principal     = "sns.amazonaws.com"
  source_arn    = "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:hl7-ninja-artifacts-${local.current_region}"
}

resource "aws_sns_topic_subscription" "deployment_handler" {
  topic_arn = "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:hl7-ninja-artifacts-${local.current_region}"
  protocol  = "lambda"
  endpoint  = module.deployment_handler.arn
}


###############################
##  appsync-app-datasource  ##
###############################
data "aws_iam_policy_document" "appsync_app_datasource" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query"
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*",
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "ssm:CreateActivation",
      "ssm:DeleteActivation",
      "ssm:DescribeActivations",
      "ssm:ListActivations",
      "ssm:DescribeInstanceInformation",
      "ssm:ListTagsForResource",
      "ssm:DeregisterManagedInstance",
      "ssm:AddTagsToResource"
    ]

    resources = [
      "*"
    ]

    sid = "SSM"
  }

  statement {
    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.hl7_app_cloud_init.arn
    ]

    sid = "SNS"
  }

  statement {
    actions = [
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminConfirmSignup",
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminSetUserPassword"
    ]

    resources = [
      aws_cognito_user_pool.hl7_ninja_apps.arn
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
}

resource "aws_iam_policy" "appsync_app_datasource" {
  description = "IAM permissions required for appsync_app_datasource lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-app-datasource"
  policy      = data.aws_iam_policy_document.appsync_app_datasource.json
}

module "appsync_app_datasource" {
  description = "Appsync datasource for managing app"

  environment_variables = {
    DYNAMODB_TABLE       = module.graph_table.name
    LOG_LEVEL            = "INFO"
    ENVIRONMENT          = var.environment_prefix
    APP_USER_POOL_ID     = aws_cognito_user_pool.hl7_ninja_apps.id
    APP_IDENTITY_POOL_ID = aws_cognito_identity_pool.hl7_ninja.id
    SSM_SERVICE_ROLE     = aws_iam_role.manage_apps_ssm_service_role.name
    APP_CLOUD_INIT_TOPIC = aws_sns_topic.hl7_app_cloud_init.name
    INBOUNDER_ECR_URL    = "${local.artifacts["hl7_mllp_inbound_node"]}:${var.hl7_ninja_version}"
    OUTBOUNDER_ECR_URL   = "${local.artifacts["hl7_mllp_outbound_node"]}:${var.hl7_ninja_version}"
    APP_CLIENT_ID        = aws_cognito_user_pool_client.hl7_ninja_apps_userpool_client.id
    COGNITO_ROLE_ARN     = aws_iam_role.authenticated.arn
    APPSYNC_ENDPOINT     = aws_appsync_graphql_api.hl7_ninja.uris["GRAPHQL"]
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-appsync-app-datasource"

  policy_arns = [
    aws_iam_policy.appsync_app_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_app_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

###############################
##  appsync-node-datasource  ##
###############################
data "aws_iam_policy_document" "appsync_node_datasource" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:DeleteItem",

    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*"
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "appsync_node_datasource" {
  description = "IAM permissions required for appsync-node-datasource lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-node-datasource"
  policy      = data.aws_iam_policy_document.appsync_node_datasource.json
}

module "appsync_node_datasource" {
  description = "Datasource for managing nodes"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
    LOG_LEVEL      = "INFO"
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-appsync-node-datasource"

  policy_arns = [
    aws_iam_policy.appsync_node_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_node_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

####################################
##  appsync-sub-field-datasource  ##
####################################
data "aws_iam_policy_document" "appsync_sub_field_datasource" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*"
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "appsync_sub_field_datasource" {
  description = "IAM permissions required for appsync-sub-field-datasource lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-sub-field-datasource"
  policy      = data.aws_iam_policy_document.appsync_sub_field_datasource.json
}

module "appsync_sub_field_datasource" {
  description = "Resolves child Appsync fields"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
    LOG_LEVEL      = "INFO"
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-appsync-sub-field-datasource"

  policy_arns = [
    aws_iam_policy.appsync_sub_field_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_sub_field_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}


##############################################
## appsync-large-message-storage-datasource ##
##############################################

resource "aws_iam_user" "presign_large_messages" {
  name = "${var.environment_prefix}-presign-large-messages"
  path = "/lambda/"

  tags = merge(local.tags, {
    lambda = "${var.environment_prefix}-appsync-large-message-storage-datasource"
  })
}

data "aws_iam_policy_document" "presign_large_messages" {
  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "${module.large_messages_bucket_us_east_1.arn}/*",
      "${module.large_messages_bucket_us_east_2.arn}/*",
      "${module.large_messages_bucket_us_west_1.arn}/*",
      "${module.large_messages_bucket_us_west_2.arn}/*",
    ]

    sid = "LargeMessagesStorageAccess"
  }

  statement {
    actions = [
      "kms:Decrypt",
    ]

    resources = [
      aws_kms_key.kms_us_east_1.arn,
      aws_kms_key.kms_us_east_2.arn,
      aws_kms_key.kms_us_west_1.arn,
      aws_kms_key.kms_us_west_2.arn
    ]

    sid = "DecryptEnvKMSKeys"
  }
}


resource "aws_iam_user_policy" "presign_large_messages" {
  user   = aws_iam_user.presign_large_messages.name
  policy = data.aws_iam_policy_document.presign_large_messages.json
}

resource "aws_iam_access_key" "presign_large_messages" {
  user = aws_iam_user.presign_large_messages.name
}

data "aws_iam_policy_document" "appsync_large_message_storage_datasource" {
  statement {
    actions = [
      "dynamodb:GetItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "appsync_large_message_storage_datasource" {
  description = "IAM permissions required for appsync-large-message-storage-datasource"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-large-message-storage-datasource"
  policy      = data.aws_iam_policy_document.appsync_large_message_storage_datasource.json
}

module "appsync_large_message_storage_datasource" {
  description     = "Returns presigned post/get for large message storage "
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    LOG_LEVEL         = "INFO"
    DYNAMODB_TABLE    = module.graph_table.name
    ENVIRONMENT       = var.environment_prefix
    ACCESS_KEY_ID     = aws_iam_access_key.presign_large_messages.id
    SECRET_ACCESS_KEY = aws_iam_access_key.presign_large_messages.secret
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
  name        = "${var.environment_prefix}-appsync-large-message-storage-datasource"

  policy_arns = [
    aws_iam_policy.appsync_large_message_storage_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_large_message_storage_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

############################################
##  appsync-validate-function-datasource ##
############################################

data "aws_iam_policy_document" "appsync_validate_function_datasource" {
  statement {
    actions = [
      "dynamodb:GetItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "appsync_validate_function_datasource" {
  description = "IAM permissions required for appsync-validate-function-datasource"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-validate-function-datasource"
  policy      = data.aws_iam_policy_document.appsync_validate_function_datasource.json
}

module "appsync_validate_function_datasource" {
  description     = "Takes in code from user and passes it to the underlying validation function "
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    LOG_LEVEL         = "INFO"
    DYNAMODB_TABLE    = module.graph_table.name
    ENVIRONMENT       = var.environment_prefix
    ACCESS_KEY_ID     = ""
    SECRET_ACCESS_KEY = ""
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
  name        = "${var.environment_prefix}-appsync-validate-function-datasource"

  policy_arns = [
    aws_iam_policy.appsync_validate_function_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_validate_function_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

######################################
##  appsync-subscription-datasource ##
######################################

data "aws_iam_policy_document" "appsync_subscription_datasource" {
  statement {
    actions = [
      "dynamodb:GetItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "appsync_subscription_datasource" {
  description = "IAM permissions required for appsync-subscription-datasource"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-subscription-datasource"
  policy      = data.aws_iam_policy_document.appsync_subscription_datasource.json
}

module "appsync_subscription_datasource" {
  description     = "Authenticates subscribers"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    LOG_LEVEL      = "INFO"
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
  name        = "${var.environment_prefix}-appsync-subscription-datasource"

  policy_arns = [
    aws_iam_policy.appsync_subscription_datasource.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["appsync_subscription_datasource"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

