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
      "arn:aws:sqs:*:*:*_db-stream_*"
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
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-dynamodb-trigger"
  policy      = data.aws_iam_policy_document.graph_table_dynamodb_trigger.json
}

module "graph_table_dynamodb_trigger" {
  description     = "Routes Dynamodb Stream events to the correct Lambda Functions"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    #TYPE_HANDLERS                = file("${path.module}/files/type-handlers-map.json")
    #GRAPH_TYPE_HANDLERS          = ""
    DYNAMODB_TABLE               = module.graph_table.name
    DEFAULT_TENANT_SQS_QUEUE_URL = aws_sqs_queue.default_tenant_sqs_queue.id
    ENVIRONMENT                  = var.environment_prefix
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
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
  timeout       = 300
  version       = "3.0.10"
}

resource "aws_lambda_event_source_mapping" "graph_table_dynamodb_trigger" {
  batch_size        = "1"
  event_source_arn  = module.graph_table.stream_arn
  function_name     = module.graph_table_dynamodb_trigger.name
  starting_position = "LATEST"
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
  description     = "Creates/removes users (In Dynamodb Table) and sends SES emails from a Dynamodb Stream"
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

  memory_size = 1536
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
  timeout       = 300
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

  statement {
    actions = [
      "cognito-idp:AdminGetUser",
    ]

    resources = [aws_cognito_user_pool.hl7_ninja_apps.arn]

    sid = "AdminGetUser"
  }
}

resource "aws_iam_policy" "graph_table_put_app_policies" {
  description = "IAM permissions required for graph-table-put-app-policies lambda"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-put-app-policies"
  policy      = data.aws_iam_policy_document.graph_table_put_app_policies.json
}

module "graph_table_put_app_policies" {
  description     = "Manages SQS/KMS resource and IAM policies from a Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    DYNAMODB_TABLE   = module.graph_table.name
    ENVIRONMENT      = var.environment_prefix
    MANAGED_APP_ROLE = aws_iam_role.authenticated.arn
    USER_POOL_ID     = aws_cognito_user_pool.hl7_ninja_apps.id
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
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
  timeout       = 300
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
  description     = "Creates/removes apps from Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
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
  timeout       = 300
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
  description     = "Creates/removes apps from Dynamodb Stream"
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

  memory_size = 1536
  name        = "${var.environment_prefix}-graph-table-manage-apps"

  policy_arns = [
    aws_iam_policy.graph_table_manage_apps.arn,
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_apps"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
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
      "${aws_appsync_graphql_api.hl7_ninja.arn}/types/mutation/*"
    ]

    sid = "AppsyncMutationQueryAccess"
  }

  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]

    resources = [
      "arn:aws:sqs:*:*:*db-stream*.fifo",
      aws_sqs_queue.default_tenant_sqs_queue.arn
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

  memory_size = 1536
  name        = "${var.environment_prefix}-graph-table-tenant-stream-handler"

  policy_arns = [
    aws_iam_policy.graph_table_tenant_stream_handler.arn,
    aws_iam_policy.additional_ddb_policy.arn,
    module.graph_table_manage_apps.invoke_policy_arn,
    module.graph_table_manage_nodes.invoke_policy_arn,
    module.graph_table_manage_message_types.invoke_policy_arn,
    module.graph_table_manage_users.invoke_policy_arn,
    module.graph_table_manage_tenants.invoke_policy_arn,
    module.graph_table_put_app_policies.invoke_policy_arn,
    module.graph_table_manage_edges.invoke_policy_arn,
    module.graph_table_manage_kms_keys.invoke_policy_arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_tenant_stream_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
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
      "lambda:GetLayerVersion",
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
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
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

  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      aws_iam_role.tenant_function_role.arn
    ]

    sid = "TenantFunctionRoleIAM"
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
    LAMBDA_ROLE_ARN            = aws_iam_role.tenant_function_role.arn
    FUNCTIONS_BUCKET           = local.artifacts_bucket
    VALIDATION_FUNCTION_S3_KEY = local.lambda_functions_keys["validate_function"]
  }

  dead_letter_arn = local.lambda_dead_letter_arn
  handler         = "function.handler"
  kms_key_arn     = local.lambda_env_vars_kms_key_arn
  memory_size     = 1536
  name            = "${var.environment_prefix}-graph-table-manage-message-types"

  policy_arns = [
    aws_iam_policy.graph_table_manage_message_types.arn
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_message_types"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.10"
}

##############################
## graph-table-manage-nodes ##
##############################
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
      "arn:aws:s3:::hl7-ninja-artifacts-${local.current_region}/${local.artifacts["tenant_lambda"]}/*"
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
  description     = "Handles nodes in the Dynamodb Stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    LOG_LEVEL                      = "INFO"
    DYNAMODB_TABLE                 = module.graph_table.name
    ENVIRONMENT                    = var.environment_prefix
    ARTIFACTS_BUCKET_PREFIX        = local.artifacts_bucket_prefix
    ROUTER_NODE_ARTIFACT           = local.lambda_functions_keys["router_node"]
    TRANS_NODE_ARTIFACT            = local.lambda_functions_keys["trans_node"]
    X_TENANT_SENDING_NODE_ARTIFACT = local.lambda_functions_keys["trans_node"]
    LAMBDA_ROLE_ARN                = aws_iam_role.tenant_function_role.arn
    MANAGED_APP_ROLE               = aws_iam_role.authenticated.arn
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
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
  timeout       = 300
  version       = "3.0.10"
}

################################
## graph-table-manage-tenants ##
################################
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
  description     = "Creates/removes tenants and their AWS resources"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    LOG_LEVEL             = "INFO"
    DYNAMODB_TABLE        = module.graph_table.name
    ENVIRONMENT           = var.environment_prefix
    TENANT_STREAM_HANDLER = module.graph_table_tenant_stream_handler.arn
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
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
  timeout       = 300
  version       = "3.0.10"
}

##############################
## graph-table-manage-edges ##
##############################
data "aws_iam_policy_document" "graph_table_manage_edges" {
  statement {
    actions = [
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
    ]

    resources = [
      "arn:aws:sqs:*:*:*_db-stream_*"
    ]

    sid = "DeleteQueue"
  }

  statement {
    actions = [
      "dynamodb:GetItem",
    ]
    resources = [
      module.graph_table.arn,
    ]

    sid = "ReadTable"
  }

  statement {
    actions = [
      "lambda:CreateEventSourceMapping",
      "lambda:GetEventSourceMapping",
      "lambda:ListEventSourceMappings",
      "lambda:DeleteEventSourceMapping",
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
}

resource "aws_iam_policy" "graph_table_manage_edges" {
  description = "IAM permissions required for graph-table-manage-edges"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-manage-edges"
  policy      = data.aws_iam_policy_document.graph_table_manage_edges.json
}

module "graph_table_manage_edges" {
  description     = "Manage edges in db stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
  name        = "${var.environment_prefix}-graph-table-manage-edges"

  policy_arns = [
    aws_iam_policy.graph_table_manage_edges.arn,
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_edges"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.10"
}

#################################
## graph-table-manage-kms-keys ##
#################################
data "aws_iam_policy_document" "graph_table_manage_kms_keys" {
  statement {
    actions = [
      "kms:ScheduleKeyDeletion",
    ]
    resources = [
      "*"
    ]

    sid = "KMSDeletion"
  }
}

resource "aws_iam_policy" "graph_table_manage_kms_keys" {
  description = "IAM permissions required for graph-table-manage-kms-keys"
  path        = "/${var.environment_prefix}-lambda/"
  name        = "${var.environment_prefix}-graph-table-manage-kms-keys"
  policy      = data.aws_iam_policy_document.graph_table_manage_kms_keys.json
}

module "graph_table_manage_kms_keys" {
  description     = "Manage kms keys on dynamodb stream"
  dead_letter_arn = local.lambda_dead_letter_arn

  environment_variables = {
    DYNAMODB_TABLE = module.graph_table.name
    ENVIRONMENT    = var.environment_prefix
  }

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn
  memory_size = 1536
  name        = "${var.environment_prefix}-graph-table-manage-kms-keys"

  policy_arns = [
    aws_iam_policy.graph_table_manage_kms_keys.arn,
  ]

  runtime       = "python3.8"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_manage_kms_keys"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.10"
}