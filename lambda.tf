## Internal Fn IAM assume role
resource "aws_iam_role" "internal_function_role" {
  name               = "${var.environment_prefix}-internal-fn-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
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
## graph-table-dynamodb-trigger ##
##################################
data "aws_iam_policy_document" "graph_table_dynamodb_trigger" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      #"dynamodb:GetItem",
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch",
      "sqs:GetQueueUrl",
    ]

    resources = [
      "arn:aws:sqs:*:*:_db-stream_*.fifo"
    ]

    sid = "DeliverMessageToQueues"
  }
}

resource "aws_iam_policy" "graph_table_dynamodb_trigger" {
  description = "IAM permissions required for graph-table-dynamodb-trigger"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-dynamodb-trigger"
  policy      = data.aws_iam_policy_document.graph_table_dynamodb_trigger.json
}

module "graph_table_dynamodb_trigger" {
  description     = "Lambda function that routes Dynamodb Stream events to the correct Lambda Functions"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    #TYPE_HANDLERS                = file("${path.module}/files/type-handlers-map.json")
    GRAPH_TYPE_HANDLERS          = ""
    DYNAMODB_TABLE               = module.graph_table.name
    DEFAULT_TENANT_SQS_QUEUE_URL = aws_sqs_queue.default_tenant_sqs_queue.id
    ENVIRONMENT                  = var.environment_prefix
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 128
  name        = "${var.environment_prefix}-graph-table-dynamodb-trigger"

  policy_arns = [
    aws_iam_policy.graph_table_dynamodb_trigger.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_dynamodb_trigger"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

###############################
## graph-table-manage-users ##
###############################
data "aws_iam_policy_document" "graph_table_manage_users" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:PutItem",
      "dynamodb:Query"
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "ses:SendTemplatedEmail",
      "ses:GetTemplate",
      "ses:ListTemplates",
      "ses:SendEmail",
    ]

    resources = [
      "*"
    ]

    sid = "SESAccess"
  }

  statement {
    actions = [
      "appsync:GraphQL",
      "appsync:GetGraphqlApi"
    ]

    resources = [
      aws_appsync_graphql_api.hl7_ninja.arn,
      "${aws_appsync_graphql_api.hl7_ninja.arn}/types/mutation/fields/StreamNotifications"
    ]

    sid = "AppsyncMutationQueryAccess"
  }
}

resource "aws_iam_policy" "graph_table_manage_users" {
  description = "IAM permissions required for graph-table-manage-users"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-manage-users"
  policy      = data.aws_iam_policy_document.graph_table_manage_users.json
}

module "graph_table_manage_users" {
  description     = "Lambda function that creates/removes users (In Dynamodb Table) and sends SES emails from a Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    DYNAMODB_TABLE         = module.graph_table.name
    EMAIL_FROM             = "support@hl7.ninja"
    EMAIL_CC               = ""
    EMAIL_REPLY_TO         = "support@hl7.ninja"
    EMAIL_RETURN_PATH      = ""
    ENVIRONMENT            = var.environment_prefix
    USER_REMOVED_TEMPLATE  = aws_ses_template.remove_user.id
    NEW_USER_TEMPLATE      = aws_ses_template.invite_user.id
    EXISTING_USER_TEMPLATE = aws_ses_template.notify_user.id
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 128
  name        = "${var.environment_prefix}-graph-table-manage-users"

  policy_arns = [
    aws_iam_policy.graph_table_manage_users.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_users"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}


##################################
## graph-table-put-app-policies ##
##################################
data "aws_iam_policy_document" "graph_table_put_app_policies" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  # statement {
  #   actions = [
  #     "appsync:GraphQL",
  #     "appsync:GetGraphqlApi"
  #   ]

  #   resources = [
  #     aws_appsync_graphql_api.hl7_ninja.arn,
  #     "${aws_appsync_graphql_api.hl7_ninja.arn}/types/mutation/fields/StreamNotifications"
  #   ]

  #   sid = "AppsyncFieldAndAPIAccess"
  # }

  # statement {
  #   actions = [
  #     "iam:CreateRole",
  #     "iam:DeleteRole",
  #     "iam:DeleteRolePolicy",
  #     "iam:GetRole",
  #     "iam:GetRolePolicy",
  #     "iam:ListRolePolicies",
  #     "iam:ListRoleTags",
  #     "iam:ListRoles",
  #     "iam:PassRole",
  #     "iam:PutRolePolicy",
  #     "iam:TagRole",
  #     "iam:UntagRole"
  #   ]

  #   resources = ["*"]

  #   sid = "IAMPermissions"
  # }

  statement {
    actions = [
      "kms:CreateGrant",
      "kms:DeleteAlias",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:ListAlias",
      "kms:ListGrants",
      "kms:ListKeyPolicies",
      "kms:ListResourceGrants",
      "kms:PutKeyPolicy",
      "kms:RevokeGrant",
      "kms:RetireGrant",
    ]

    resources = ["*"]

    sid = "KMSPermissions"
  }

  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:RemovePermission",
      "sqs:SetQueueAttributes",
      "sqs:AddPermission",
    ]

    resources = ["*"]

    sid = "SQSPermissions"
  }
}

resource "aws_iam_policy" "graph_table_put_app_policies" {
  description = "IAM permissions required for graph-table-put-app-policies lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-put-app-policies"
  policy      = data.aws_iam_policy_document.graph_table_put_app_policies.json
}

module "graph_table_put_app_policies" {
  description     = "Lambda function that manages SQS/KMS resource and IAM policies from a Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    DYNAMODB_TABLE   = module.graph_table.name
    ENVIRONMENT      = var.environment_prefix
    MANAGED_APP_ROLE = aws_iam_role.authenticated.arn
    USER_POOL_ID     = aws_cognito_user_pool.hl7_ninja_apps.id
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 128
  name        = "${var.environment_prefix}-graph-table-put-app-policies"

  policy_arns = [
    aws_iam_policy.graph_table_put_app_policies.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_put_app_policies"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

##################################
##  graph-table-manage-queues   ##
##################################
data "aws_iam_policy_document" "graph_table_manage_queues" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:UpdateItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "appsync:GraphQL",
      "appsync:GetGraphqlApi"
    ]

    resources = [
      aws_appsync_graphql_api.hl7_ninja.arn,
      "${aws_appsync_graphql_api.hl7_ninja.arn}/types/mutation/fields/StreamNotifications"
    ]

    sid = "AppsyncFieldAndAPIAccess"
  }

  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:RemovePermission",
      "sqs:AddPermission",
    ]

    resources = ["*"]

    sid = "SQSPermissions"
  }
}

resource "aws_iam_policy" "graph_table_manage_queues" {
  description = "IAM permissions required for graph-table-manage-queues lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-manage-queues"
  policy      = data.aws_iam_policy_document.graph_table_manage_queues.json
}

module "graph_table_manage_queues" {
  description     = "Lambda function that creates/removes apps from Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 128
  name        = "${var.environment_prefix}-graph-table-manage-queues"

  policy_arns = [
    aws_iam_policy.graph_table_manage_queues.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_queues"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}


##################################
##  appsync-kms-key-datasource  ##
##################################
data "aws_iam_policy_document" "appsync_kms_key_datasource" {
  statement {
    actions = [
      "kms:CreateKey",
      "kms:CreateAlias",
      "kms:DeleteAlias",
      "kms:DescribeKey",
      "kms:ListAliases",
      "kms:ListGrants",
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
  description     = "Lambda function that manages SQS/KMS resource and IAM policies from a Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn
  environment_variables = {

    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
    LOG_LEVEL      = "INFO"

  }
  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 128
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
      "arn:aws:sqs:::db_stream*"
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
      module.graph_table_tenant_stream_handler.arn
    ]

    sid = "LambdaEventSourceMappings"
  }

  statement {
    actions = [
      "dynamodb:Query",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]

    resources = [
      "${module.graph_table.arn}/*",
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }
}

resource "aws_iam_policy" "appsync_tenant_datasource" {
  description = "IAM permissions required for appsync-tenant-datasource lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-appsync-tenant-datasource"
  policy      = data.aws_iam_policy_document.appsync_tenant_datasource.json
}

module "appsync_tenant_datasource" {
  description     = "Lambda function that creates/removes tenants and their AWS resources"
  dead_letter_arn = local.lambda_dead_letter_arn
  environment_variables = {
    DYNAMODB_TABLE          = module.graph_table.name
    ENVIRONMENT             = var.environment_prefix
    LOG_LEVEL               = "INFO"
    STREAM_HANDLER_FUNCTION = module.graph_table_tenant_stream_handler.arn
  }
  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 128
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
  description = "Lambda function that gets triggered when cognito user to be authenticated"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
    INDEX_NAME     = "gsi0"
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 128
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
  description = "Lambda function that customize the claims in the identity token"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 128
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

###############################
##  appsync-edge-datasource  ##
###############################
data "aws_iam_policy_document" "appsync_edge_datasource" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
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
      "arn:aws:sqs:::db_stream*"
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
  memory_size     = 128
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

###############################
##  graph-table-manage-apps  ##
###############################
data "aws_iam_policy_document" "graph_table_manage_apps" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  # statement {
  #   actions = [
  #     "ssm:CreateActivation",
  #     "ssm:DeleteActivation",
  #     "ssm:DescribeActivations",
  #     "ssm:ListActivations",
  #     "ssm:DescribeInstanceInformation",
  #     "ssm:ListTagsForResource",
  #     "ssm:DeregisterManagedInstance"
  #   ]

  #   resources = [

  #   ]

  #   sid = "SSMAccess"
  # }

  # statement {
  #   actions = [
  #     "sns:Publish"
  #   ]

  #   resources = [

  #   ]

  #   sid = "SNSPublish"
  # }

  statement {
    actions = [
      "cognito:AdminCreateUser",
      "cognito:AdminConfirmSignup",
      "cognito:AdminDeleteUser",
      "cognito:AdminGetUser",
      "cognito:AdminResetUserPassword"
    ]

    resources = [
      aws_cognito_user_pool.hl7_ninja_apps.arn
    ]

    sid = "AppCognitoPoolAccess"
  }

  statement {
    actions = [
      "appsync:GraphQL",
      "appsync:GetGraphqlApi"
    ]

    resources = [
      aws_appsync_graphql_api.hl7_ninja.arn,
      "${aws_appsync_graphql_api.hl7_ninja.arn}/types/mutation/fields/StreamNotifications"
    ]

    sid = "AppsyncMutationQueryAccess"
  }
}

resource "aws_iam_role" "manage_apps_ssm_service_role" {
  description        = "Enable AWS Systems Manager service core functionality"
  name               = "${var.environment_prefix}-manage-apps-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.manage_apps_ssm_service_role.json
  tags               = local.tags
}

data "aws_iam_policy_document" "manage_apps_ssm_service_role" {
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

resource "aws_iam_role_policy_attachment" "manage_apps_ssm_service_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.manage_apps_ssm_service_role.name
}

resource "aws_iam_policy" "graph_table_manage_apps" {
  description = "IAM permissions required for graph-table-manage-apps"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-manage-apps"
  policy      = data.aws_iam_policy_document.graph_table_manage_apps.json
}

module "graph_table_manage_apps" {
  description     = "Lambda function that creates/removes apps from Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    DYNAMODB_TABLE       = module.graph_table.name
    APP_USER_POOL_ID     = aws_cognito_user_pool.hl7_ninja_apps.id
    APP_IDENTITY_POOL_ID = aws_cognito_identity_pool.hl7_ninja.id
    SSM_EXPIRATION       = ""
    SSM_SERVICE_ROLE     = aws_iam_role.manage_apps_ssm_service_role.arn
    APP_CLOUD_INIT_TOPIC = aws_sns_topic.hl7_app_cloud_init.name
    ENVIRONMENT          = var.environment_prefix
    INBOUNDER_ECR_URL    = "${local.artifacts["hl7_mllp_inbound_node"]}:${var.hl7_ninja_version}"
    OUTBOUNDER_ECR_URL   = "${local.artifacts["hl7_mllp_outbound_node"]}:${var.hl7_ninja_version}"
  }


  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 128
  name        = "${var.environment_prefix}-graph-table-manage-apps"

  policy_arns = [
    aws_iam_policy.graph_table_manage_apps.arn,
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_apps"]
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
      "dynamodb:DescribeTable",
      "dynamodb:UpdateItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:PutItem",
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
  memory_size     = 128
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
  memory_size     = 128
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

#############################
##  ui-cognito-pre-signup  ##
#############################
data "aws_iam_policy_document" "ui_cognito_pre_signup" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:Query"
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*",
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
  memory_size     = 128
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
  memory_size     = 128
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
  memory_size     = 128
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
  memory_size   = 128
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
## graph-table-tenant-stream-handler ##
#######################################
data "aws_iam_policy_document" "graph_table_tenant_stream_handler" {
  statement {
    actions = [
      "dynamodb:GetItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "appsync:GraphQL",
      "appsync:GetGraphqlApi"
    ]

    resources = [
      aws_appsync_graphql_api.hl7_ninja.arn,
      "${aws_appsync_graphql_api.hl7_ninja.arn}/types/mutation/fields/StreamNotifications"
    ]

    sid = "AppsyncMutationQueryAccess"
  }

  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      "arn:aws:sqs:*:*:*db_stream*.fifo"
    ]

    sid = "PrerequisitesForQueueTrigger"
  }
}

resource "aws_iam_policy" "graph_table_tenant_stream_handler" {
  description = "IAM permissions required for graph-table-tenant-stream-handler"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-tenant-stream-handler"
  policy      = data.aws_iam_policy_document.graph_table_tenant_stream_handler.json
}

module "graph_table_tenant_stream_handler" {
  description     = "Delegates calls to handling lambda functions in HL7-Ninja Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    TYPE_HANDLERS  = file("${path.module}/files/type-handlers-map.json")
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 128
  name        = "${var.environment_prefix}-graph-table-tenant-stream-handler"

  policy_arns = [
    aws_iam_policy.graph_table_tenant_stream_handler.arn,
    aws_iam_policy.additional_ddb_policy.arn,
    module.graph_table_manage_apps.invoke_policy_arn,
    module.graph_table_manage_queues.invoke_policy_arn,
    module.graph_table_manage_users.invoke_policy_arn,
    module.graph_table_put_app_policies.invoke_policy_arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_tenant_stream_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

resource "aws_lambda_event_source_mapping" "graph_table_tenant_stream_handler" {
  function_name    = module.graph_table_tenant_stream_handler.arn
  event_source_arn = aws_sqs_queue.default_tenant_sqs_queue.arn
}

######################################
## graph-table-manage-message-types ##
######################################
data "aws_iam_policy_document" "graph_table_manage_message_types" {
  statement {
    actions = [
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:PublishLayerVersion",
      "lambda:UpdateFunctionConfiguration",
      "lambda:DeleteFunction",
      "lambda:DeleteLayerVersion",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaAllAccess"
  }

  statement {
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Update"
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*"
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::hl7-ninja-artifacts-${local.current_region}/${local.artifacts["lambda"]}/*"
    ]

    sid = "GetValidateFnLambda"
  }
}

resource "aws_iam_policy" "graph_table_manage_message_types" {
  description = "IAM permissions required for graph-table-manage-message-types"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-manage-message-types"
  policy      = data.aws_iam_policy_document.graph_table_manage_message_types.json
}

module "graph_table_manage_message_types" {
  description = "No Description"

  environment_variables = {
    DYNAMODB_TABLE             = module.graph_table.name
    ENVIRONMENT                = var.environment_prefix
    LAMBDA_ROLE_ARN            = aws_iam_role.internal_function_role.arn
    FUNCTIONS_BUCKET           = local.artifacts_bucket
    VALIDATION_FUNCTION_S3_KEY = local.lambda_functions_keys["validate_function"]
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 128
  name            = "${var.environment_prefix}-graph-table-manage-message-types"

  policy_arns = [
    aws_iam_policy.graph_table_manage_message_types.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_message_types"]
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
  description = "No Description"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
    LOG_LEVEL      = "INFO"
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 128
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
}

resource "aws_iam_policy" "deployment_handler" {
  description = "IAM permissions required for deployment-handler lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-deployment-handler"
  policy      = data.aws_iam_policy_document.deployment_handler.json
}

module "deployment_handler" {
  description = "Does appropriate deployments by getting invoked by Objects created on Artifacts bucket"

  environment_variables = {
    HL7_NINJA_VERSION = var.hl7_ninja_version
    ENVIRONMENT       = var.environment_prefix
    ARTIFACTS_BUCKET  = local.artifacts_bucket
    API_ID            = aws_appsync_graphql_api.hl7_ninja.id
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 128
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
      "dynamodb:DescribeTable",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem"
    ]

    resources = [
      module.graph_table.arn,
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
      "arn:aws:sns:${local.current_region}:${local.artifacts_account_id}:hl7-ninja-artifacts-${local.current_region}"
    ]

    sid = "SNS"
  }

  statement {
    actions = [
      "cognito:AdminCreateUser",
      "cognito:AdminConfirmSignup",
      "cognito:AdminDeleteUser",
      "cognito:AdminGetUser",
      "cognito:AdminResetUserPassword"
    ]

    resources = [
      aws_cognito_user_pool.hl7_ninja_apps.arn
    ]

    sid = "AppCognitoPoolAccess"
  }
  statement {
    actions = [
      "iam:CreateRole",
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
    SSM_SERVICE_ROLE     = aws_iam_role.manage_apps_ssm_service_role.arn
    APP_CLOUD_INIT_TOPIC = aws_sns_topic.hl7_app_cloud_init.name
    INBOUNDER_ECR_URL    = "${local.artifacts["hl7_mllp_inbound_node"]}:${var.hl7_ninja_version}"
    OUTBOUNDER_ECR_URL   = "${local.artifacts["hl7_mllp_outbound_node"]}:${var.hl7_ninja_version}"
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 128
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
  description = "No Description"

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
    LOG_LEVEL      = "INFO"
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 128
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
  memory_size     = 128
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

###############################
## graph-table-manage-nodes ##
###############################
data "aws_iam_policy_document" "graph_table_manage_nodes" {
  statement {
    actions = [
      "dynamodb:GetItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:TagFunction",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaAccess"
  }

  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::hl7-ninja-artifacts-${local.current_region}/${local.artifacts["lambda"]}/*"
    ]

    sid = "GetArtifacts"
  }
}

resource "aws_iam_policy" "graph_table_manage_nodes" {
  description = "IAM permissions required for graph-table-manage-nodes"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-manage-nodes"
  policy      = data.aws_iam_policy_document.graph_table_manage_nodes.json
}

module "graph_table_manage_nodes" {
  description     = "Lambda function that handles nodes in the Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    LOG_LEVEL                      = "INFO"
    DYNAMODB_TABLE                 = module.graph_table.name
    ENVIRONMENT                    = var.environment_prefix
    ARTIFACTS_BUCKET_PREFIX        = local.artifacts_bucket_prefix
    ROUTER_NODE_ARTIFACT           = local.lambda_functions_keys["router_node"]
    TRANS_NODE_ARTIFACT            = local.lambda_functions_keys["trans_node"]
    X_TENANT_SENDING_NODE_ARTIFACT = local.lambda_functions_keys["trans_node"]
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 128
  name        = "${var.environment_prefix}-graph-table-manage-nodes"

  policy_arns = [
    aws_iam_policy.graph_table_manage_nodes.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_nodes"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

###############################
## graph-table-manage-tenants ##
###############################
data "aws_iam_policy_document" "graph_table_manage_tenants" {
  statement {
    actions = [
      "appsync:GetGraphqlApi",
      "appsync:GraphQL",
    ]

    resources = [
      "arn:aws:appsync:${local.current_region}:${var.allowed_account_id}:apis/${aws_appsync_graphql_api.hl7_ninja.id}",
      "arn:aws:appsync:${local.current_region}:${var.allowed_account_id}:apis/${aws_appsync_graphql_api.hl7_ninja.id}/types/mutation/fields/*",
    ]

    sid = "AppSync"
  }

  statement {
    actions = [
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
    ]

    resources = [
      "*",
    ]

    sid = "Sqs"
  }
  statement {
    actions = [
      "lambda:DeleteEventSourceMapping",
      "lambda:GetEventSourceMapping",
      "lambda:ListEventSourceMappings",
    ]

    resources = [
      "*",
    ]

    sid = "LambdaAccess"
  }
  statement {
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:Query",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*",
    ]

    sid = "TableAccess"
  }

  statement {
    actions = [
      "kms:ScheduleKeyDeletion",
    ]

    resources = [
      "*",
    ]

    sid = "KMS"
  }
}

resource "aws_iam_policy" "graph_table_manage_tenants" {
  description = "IAM permissions required for graph-table-manage-tenants"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-manage-tenants"
  policy      = data.aws_iam_policy_document.graph_table_manage_tenants.json
}

module "graph_table_manage_tenants" {
  description     = "Lambda function that creates/removes tenants and their AWS resources"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    LOG_LEVEL             = "INFO"
    DYNAMODB_TABLE        = module.graph_table.name
    ENVIRONMENT           = var.environment_prefix
    TENANT_STREAM_HANDLER = module.graph_table_tenant_stream_handler.arn
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 128
  name        = "${var.environment_prefix}-graph-table-manage-tenants"

  policy_arns = [
    aws_iam_policy.graph_table_manage_tenants.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_tenants"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 30
  version       = "3.0.10"
}

##############################################
## appsync-large-message-storage-datasource ##
##############################################

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
    ACCESS_KEY_ID     = ""
    SECRET_ACCESS_KEY = ""
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 128
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

  memory_size = 128
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

  memory_size = 128
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