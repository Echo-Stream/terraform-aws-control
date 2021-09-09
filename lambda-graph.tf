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
      "dynamodb:PutItem"
    ]

    resources = [
      module.graph_table.stream_arn,
    ]

    sid = "AllowReadingFromStreams"
  }

  statement {
    actions = [
      "dynamodb:PutItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "WriteAccesstoTable"
  }
}

resource "aws_iam_policy" "graph_table_dynamodb_trigger" {
  description = "IAM permissions required for graph-table-dynamodb-trigger"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-graph-table-dynamodb-trigger"
  policy      = data.aws_iam_policy_document.graph_table_dynamodb_trigger.json
}

module "graph_table_dynamodb_trigger" {
  description           = "Routes Dynamodb Stream events to the correct Lambda Functions"
  dead_letter_arn       = local.lambda_dead_letter_arn
  environment_variables = local.common_lambda_environment_variables

  handler     = "function.handler"
  kms_key_arn = local.lambda_env_vars_kms_key_arn

  memory_size = 1536
  name        = "${var.resource_prefix}-graph-table-dynamodb-trigger"

  policy_arns = [
    aws_iam_policy.graph_table_dynamodb_trigger.arn,
    aws_iam_policy.additional_ddb_policy.arn
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_dynamodb_trigger"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.14"
}

resource "aws_lambda_event_source_mapping" "graph_table_dynamodb_trigger" {
  batch_size        = "1"
  event_source_arn  = module.graph_table.stream_arn
  function_name     = module.graph_table_dynamodb_trigger.name
  starting_position = "LATEST"
}

resource "aws_cloudwatch_log_subscription_filter" "graph_table_dynamodb_trigger" {
  name            = "${var.resource_prefix}-graph-table-dynamodb-trigger"
  log_group_name  = module.graph_table_dynamodb_trigger.log_group_name
  filter_pattern  = "ERROR -USERERROR"
  destination_arn = module.control_alert_handler.arn
}


resource "aws_iam_role" "manage_apps_ssm_service_role" {
  description        = "Enable AWS Systems Manager service core functionality"
  name               = "${var.resource_prefix}-manage-apps-ssm-role"
  path               = "/service-role/"
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

data "aws_iam_policy_document" "manage_apps_ssm_service_role_customer_policy" {
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
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*"
    ]

    sid = "LogsAccess"
  }
}

resource "aws_iam_policy" "manage_apps_ssm_service_role_customer_policy" {
  description = "IAM permissions required for manage apps ssm"
  path        = "/${var.resource_prefix}-lambda/"
  policy      = data.aws_iam_policy_document.manage_apps_ssm_service_role_customer_policy.json
}

resource "aws_iam_role_policy_attachment" "manage_apps_ssm_service_role_customer_policy" {
  policy_arn = aws_iam_policy.manage_apps_ssm_service_role_customer_policy.arn
  role       = aws_iam_role.manage_apps_ssm_service_role.name
}

resource "aws_iam_role_policy_attachment" "manage_apps_ssm_service_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.manage_apps_ssm_service_role.name
}

resource "aws_iam_role_policy_attachment" "manage_apps_ssm_directory_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
  role       = aws_iam_role.manage_apps_ssm_service_role.name
}

#######################################
## graph-table-tenant-stream-handler ##
#######################################
data "aws_iam_policy_document" "graph_table_tenant_stream_handler" {
  statement {
    actions = [
      "dynamodb:*",
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
      aws_appsync_graphql_api.echostream.arn,
    ]

    sid = "AppsyncAccess"
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
      aws_sqs_queue.system_sqs_queue.arn
    ]

    sid = "PrerequisitesForQueueTrigger"
  }

  statement {
    actions = [
      "ses:GetTemplate",
      "ses:ListTemplates",
      "ses:SendEmail",
      "ses:SendTemplatedEmail",
    ]

    resources = [
      "*"
    ]

    sid = "SESAccess"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteSubscriptionFilter",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminUserGlobalSignOut",
      "cognito-idp:ListUsers",
    ]

    resources = [aws_cognito_user_pool.echostream_apps.arn,
      aws_cognito_user_pool.echostream_ui.arn,
    aws_cognito_user_pool.echostream_api.arn]

    sid = "AdminGetUser"
  }


  statement {
    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:ListGrants",
      "kms:ListResourceGrants",
      "kms:RetireGrant",
      "kms:RevokeGrant",
      "kms:ScheduleKeyDeletion",
    ]

    resources = ["*"]

    sid = "KMSPermissions"
  }

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

    sid = "ECRAccess"
  }

  statement {
    actions = [
      "lambda:DeleteEventSourceMapping",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:DeleteLayerVersion",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetLayerVersion",
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions",
      "lambda:PublishLayerVersion",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaAllAccess"
  }


  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${local.artifacts["lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${local.artifacts["lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${local.artifacts["lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${local.artifacts["tenant_lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${local.artifacts["tenant_lambda"]}/*",
      "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${local.artifacts["tenant_lambda"]}/*",
    ]

    sid = "GetArtifacts"
  }

  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      aws_iam_role.tenant_function.arn
    ]

    sid = "TenantFunctionRoleIAM"
  }

  statement {
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "graph_table_tenant_stream_handler" {
  description = "IAM permissions required for graph-table-tenant-stream-handler"
  path        = "/${var.resource_prefix}-lambda/"
  name        = "${var.resource_prefix}-graph-table-tenant-stream-handler"
  policy      = data.aws_iam_policy_document.graph_table_tenant_stream_handler.json
}

module "graph_table_tenant_stream_handler" {
  description           = "Delegates calls to handling lambda functions in EchoStream Dynamodb Stream"
  dead_letter_arn       = local.lambda_dead_letter_arn
  environment_variables = local.common_lambda_environment_variables
  handler               = "function.handler"
  kms_key_arn           = local.lambda_env_vars_kms_key_arn
  memory_size           = 1536
  name                  = "${var.resource_prefix}-graph-table-tenant-stream-handler"

  policy_arns = [
    aws_iam_policy.graph_table_tenant_stream_handler.arn,
    aws_iam_policy.additional_ddb_policy.arn,
    #module.graph_table_manage_apps.invoke_policy_arn,
    #module.graph_table_manage_nodes.invoke_policy_arn,
    #module.graph_table_manage_message_types.invoke_policy_arn,
    #module.graph_table_manage_users.invoke_policy_arn,
    #module.graph_table_manage_tenants.invoke_policy_arn,
    #module.graph_table_manage_resource_policies.invoke_policy_arn,
    #module.graph_table_manage_edges.invoke_policy_arn,
    #module.graph_table_manage_kms_keys.invoke_policy_arn
  ]

  runtime       = "python3.9"
  s3_bucket     = local.artifacts_bucket
  s3_object_key = local.lambda_functions_keys["graph_table_tenant_stream_handler"]
  source        = "QuiNovas/lambda/aws"
  tags          = local.tags
  timeout       = 300
  version       = "3.0.14"
}

resource "aws_lambda_event_source_mapping" "graph_table_tenant_stream_handler" {
  function_name    = module.graph_table_tenant_stream_handler.arn
  event_source_arn = aws_sqs_queue.system_sqs_queue.arn
}

resource "aws_cloudwatch_log_subscription_filter" "graph_table_tenant_stream_handler" {
  name            = "${var.resource_prefix}-graph-table-tenant-stream-handler"
  log_group_name  = module.graph_table_tenant_stream_handler.log_group_name
  filter_pattern  = "ERROR -USERERROR"
  destination_arn = module.control_alert_handler.arn
}

# ###############################
# ## graph-table-manage-users ##
# ###############################
# data "aws_iam_policy_document" "graph_table_manage_users" {
#   statement {
#     actions = [
#       "dynamodb:DeleteItem",
#       "dynamodb:DescribeTable",
#       "dynamodb:PutItem",
#       "dynamodb:Query",
#     ]

#     resources = [
#       module.graph_table.arn,
#     ]

#     sid = "TableAccess"
#   }

#   statement {
#     actions = [
#       "ses:GetTemplate",
#       "ses:ListTemplates",
#       "ses:SendEmail",
#       "ses:SendTemplatedEmail",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "SESAccess"
#   }

#   statement {
#     actions = [
#       "appsync:GraphQL",
#       "appsync:GetGraphqlApi"
#     ]

#     resources = [
#       aws_appsync_graphql_api.echostream.arn,
#       "${aws_appsync_graphql_api.echostream.arn}/types/Mutation/fields/StreamNotifications",
#     ]

#     sid = "AppsyncMutationQueryAccess"
#   }

#   statement {
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "LogsAccess"
#   }

#   statement {
#     actions = [
#       "cognito-idp:AdminDeleteUser",
#     ]

#     resources = [
#       aws_cognito_user_pool.echostream_api.arn
#     ]

#     sid = "DeleteApiUser"
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_users" {
#   description = "IAM permissions required for graph-table-manage-users"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-users"
#   policy      = data.aws_iam_policy_document.graph_table_manage_users.json
# }

# module "graph_table_manage_users" {
#   description     = "Creates/removes users (In Dynamodb Table) and sends SES emails from a Dynamodb Stream"
#   dead_letter_arn = local.lambda_dead_letter_arn

#   environment_variables = {
#     API_USER_POOL_ID       = aws_cognito_user_pool.echostream_api.id
#     DYNAMODB_TABLE         = module.graph_table.name
#     EMAIL_CC               = var.ses_email_address
#     EMAIL_FROM             = var.ses_email_address
#     EMAIL_REPLY_TO         = var.ses_email_address
#     EMAIL_RETURN_PATH      = var.ses_email_address
#     ENVIRONMENT            = var.resource_prefix
#     EXISTING_USER_TEMPLATE = aws_ses_template.notify_user.id
#     INTERNAL_APPSYNC_ROLES = local.internal_appsync_role_names
#     NEW_USER_TEMPLATE      = aws_ses_template.invite_user.id
#     USER_REMOVED_TEMPLATE  = aws_ses_template.remove_user.id
#   }

#   handler     = "function.handler"
#   kms_key_arn = local.lambda_env_vars_kms_key_arn

#   memory_size = 1536
#   name        = "${var.resource_prefix}-graph-table-manage-users"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_users.arn,
#     aws_iam_policy.additional_ddb_policy.arn
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_users"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_users" {
#   name            = "${var.resource_prefix}-graph-table-manage-users"
#   log_group_name  = module.graph_table_manage_users.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }

# ##################################
# ## graph-table-manage-resource-policies ##
# ##################################
# data "aws_iam_policy_document" "graph_table_manage_resource_policies" {
#   statement {
#     actions = [
#       "dynamodb:GetItem",
#       "dynamodb:PutItem",
#       "dynamodb:Query",
#       "dynamodb:UpdateItem"
#     ]

#     resources = [
#       module.graph_table.arn,
#     ]

#     sid = "TableAccess"
#   }

#   statement {
#     actions = [
#       "kms:CreateGrant",
#       "kms:DescribeKey",
#       "kms:ListGrants",
#       "kms:ListResourceGrants",
#       "kms:RevokeGrant",
#       "kms:RetireGrant",
#     ]

#     resources = ["*"]

#     sid = "KMSPermissions"
#   }

#   statement {
#     actions = [
#       "sqs:GetQueueAttributes",
#       "sqs:GetQueueUrl",
#       "sqs:ListQueues",
#       "sqs:SetQueueAttributes",
#     ]

#     resources = ["*"]

#     sid = "SQSPermissions"
#   }

#   statement {
#     actions = [
#       "cognito-idp:AdminGetUser",
#     ]

#     resources = [aws_cognito_user_pool.echostream_apps.arn]

#     sid = "AdminGetUser"
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_resource_policies" {
#   description = "IAM permissions required for graph-table-manage-resource-policies lambda"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-resource-policies"
#   policy      = data.aws_iam_policy_document.graph_table_manage_resource_policies.json
# }

# module "graph_table_manage_resource_policies" {
#   description     = "Manages SQS/KMS resource and IAM policies from a Dynamodb Stream"
#   dead_letter_arn = local.lambda_dead_letter_arn

#   environment_variables = {
#     DYNAMODB_TABLE         = module.graph_table.name
#     ENVIRONMENT            = var.resource_prefix
#     INTERNAL_APPSYNC_ROLES = local.internal_appsync_role_names
#     MANAGED_APP_ROLE       = aws_iam_role.authenticated.arn
#     NODE_FUNCTION_ROLE     = aws_iam_role.tenant_function.arn
#     USER_POOL_ID           = aws_cognito_user_pool.echostream_apps.id
#   }

#   handler     = "function.handler"
#   kms_key_arn = local.lambda_env_vars_kms_key_arn

#   memory_size = 1536
#   name        = "${var.resource_prefix}-graph-table-manage-resource-policies"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_resource_policies.arn,
#     aws_iam_policy.additional_ddb_policy.arn
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_resource_policies"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_resource_policies" {
#   name            = "${var.resource_prefix}-graph-table-manage-resource-policies"
#   log_group_name  = module.graph_table_manage_resource_policies.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }


# ###############################
# ##  graph-table-manage-apps  ##
# ###############################
# data "aws_iam_policy_document" "graph_table_manage_apps" {
#  
#   statement {
#     actions = [
#       "kms:CreateGrant",
#       "kms:DescribeKey",
#       "kms:ListGrants",
#       "kms:ListResourceGrants",
#       "kms:RevokeGrant",
#       "kms:RetireGrant",
#     ]

#     resources = ["*"]

#     sid = "KMSPermissions"
#   }

#   statement {
#     actions = [
#       "sqs:GetQueueAttributes",
#       "sqs:GetQueueUrl",
#       "sqs:ListQueues",
#       "sqs:SetQueueAttributes",
#     ]

#     resources = ["*"]

#     sid = "SQSPermissions"
#   }

#   statement {
#     actions = [
#       "cognito-idp:AdminGetUser",
#     ]

#     resources = [aws_cognito_user_pool.echostream_apps.arn]

#     sid = "AdminGetUser"
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_apps" {
#   description = "IAM permissions required for graph-table-manage-apps"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-apps"
#   policy      = data.aws_iam_policy_document.graph_table_manage_apps.json
# }

# module "graph_table_manage_apps" {
#   description     = "Creates/removes apps from Dynamodb Stream"
#   dead_letter_arn = local.lambda_dead_letter_arn

#   environment_variables = {
#     APP_USER_POOL_ID = aws_cognito_user_pool.echostream_apps.id
#     DYNAMODB_TABLE   = module.graph_table.name
#   }


#   handler     = "function.handler"
#   kms_key_arn = local.lambda_env_vars_kms_key_arn

#   memory_size = 1536
#   name        = "${var.resource_prefix}-graph-table-manage-apps"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_apps.arn,
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_apps"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_apps" {
#   name            = "${var.resource_prefix}-graph-table-manage-apps"
#   log_group_name  = module.graph_table_manage_apps.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }

# ######################################
# ## graph-table-manage-message-types ##
# ######################################
# data "aws_iam_policy_document" "graph_table_manage_message_types" {
#   statement {
#     actions = [
#       "lambda:CreateFunction",
#       "lambda:GetFunction",
#       "lambda:PublishLayerVersion",
#       "lambda:UpdateFunctionConfiguration",
#       "lambda:DeleteFunction",
#       "lambda:ListFunctions",
#       "lambda:DeleteLayerVersion",
#       "lambda:GetLayerVersion",
#       "lambda:GetFunctionConfiguration",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "LambdaAllAccess"
#   }

#   statement {
#     effect = "Deny"

#     actions = [
#       "lambda:DeleteFunction",
#     ]

#     resources = [
#       "arn:aws:lambda:${local.current_region}:${data.aws_caller_identity.current.account_id}:function:echo-dev-*"
#     ]

#     sid = "DenyDeletingControlFunctions"
#   }

#   statement {
#     actions = [
#       "dynamodb:BatchWriteItem",
#       "dynamodb:PutItem",
#       "dynamodb:GetItem",
#       "dynamodb:Query",
#       "dynamodb:UpdateItem",
#       "dynamodb:DeleteItem"
#     ]

#     resources = [
#       module.graph_table.arn,
#       "${module.graph_table.arn}/index/*"
#     ]

#     sid = "TableAccess"
#   }

#   statement {
#     actions = [
#       "s3:GetObject*",
#     ]

#     resources = [
#       "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${local.artifacts["lambda"]}/*",
#       "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${local.artifacts["lambda"]}/*",
#       "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${local.artifacts["lambda"]}/*",
#     ]

#     sid = "GetValidateFnLambda"
#   }

#   statement {
#     actions = [
#       "iam:PassRole",
#     ]

#     resources = [
#       aws_iam_role.tenant_function.arn
#     ]

#     sid = "TenantFunctionRoleIAM"
#   }

#   statement {
#     actions = [
#       "kms:CreateGrant",
#       "kms:RetireGrant",
#     ]

#     resources = ["*"]

#     sid = "KMSCreateRetireGrantAll"
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_message_types" {
#   description = "IAM permissions required for graph-table-manage-message-types"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-message-types"
#   policy      = data.aws_iam_policy_document.graph_table_manage_message_types.json
# }

# module "graph_table_manage_message_types" {
#   description = "No Description"

#   environment_variables = {
#     AVAILABLE_REGIONS          = "[\"us-east-1\", \"us-east-2\"]"
#     DYNAMODB_TABLE             = module.graph_table.name
#     ENVIRONMENT                = var.resource_prefix
#     FUNCTIONS_BUCKET           = local.artifacts_bucket_prefix
#     INTERNAL_APPSYNC_ROLES     = local.internal_appsync_role_names
#     LAMBDA_ROLE_ARN            = aws_iam_role.validate_functions_tenant_function.arn
#     VALIDATION_FUNCTION_S3_KEY = local.lambda_functions_keys["validate_function"]
#   }

#   dead_letter_arn = local.lambda_dead_letter_arn
#   handler         = "function.handler"
#   kms_key_arn     = local.lambda_env_vars_kms_key_arn
#   memory_size     = 1536
#   name            = "${var.resource_prefix}-graph-table-manage-message-types"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_message_types.arn
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_message_types"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_message_types" {
#   name            = "${var.resource_prefix}-graph-table-manage-message-types"
#   log_group_name  = module.graph_table_manage_message_types.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }

# ##############################
# ## graph-table-manage-nodes ##
# ##############################
# data "aws_iam_policy_document" "graph_table_manage_nodes" {
#   statement {
#     actions = [
#       "dynamodb:DeleteItem",
#       "dynamodb:GetItem",
#       "dynamodb:UpdateItem",
#     ]

#     resources = [
#       module.graph_table.arn,
#     ]

#     sid = "TableAccess"
#   }

#   statement {
#     actions = [
#       "kms:CreateGrant",
#       "kms:RetireGrant",
#     ]

#     resources = ["*"]

#     sid = "KMSPermissions"
#   }

#   statement {
#     actions = [
#       "logs:PutSubscriptionFilter",
#       "logs:DeleteSubscriptionFilter",
#       "logs:PutRetentionPolicy",
#       "logs:CreateLogGroup",
#       "logs:DeleteLogGroup",
#     ]

#     resources = [
#       "*"
#     ]

#   }

#   statement {
#     actions = [
#       "lambda:CreateFunction",
#       "lambda:DeleteFunction",
#       "lambda:TagFunction",
#       "lambda:GetLayerVersion",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "LambdaAccess"
#   }

#   statement {
#     effect = "Deny"

#     actions = [
#       "lambda:DeleteFunction",
#     ]

#     resources = [
#       "arn:aws:lambda:${local.current_region}:${data.aws_caller_identity.current.account_id}:function:echo-dev-*"
#     ]

#     sid = "DenyDeletingControlFunctions"
#   }
#   statement {
#     actions = [
#       "s3:GetObject*",
#     ]

#     resources = [
#       "arn:aws:s3:::${local.artifacts_bucket_prefix}-${local.current_region}/${local.artifacts["tenant_lambda"]}/*",
#       "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-east-2/${local.artifacts["tenant_lambda"]}/*",
#       "arn:aws:s3:::${local.artifacts_bucket_prefix}-us-west-2/${local.artifacts["tenant_lambda"]}/*",
#     ]

#     sid = "GetArtifacts"
#   }

#   statement {
#     actions = [
#       "iam:PassRole",
#     ]

#     resources = [
#       aws_iam_role.tenant_function.arn
#     ]

#     sid = "TenantFunctionRoleIAM"
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_nodes" {
#   description = "IAM permissions required for graph-table-manage-nodes"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-nodes"
#   policy      = data.aws_iam_policy_document.graph_table_manage_nodes.json
# }

# module "graph_table_manage_nodes" {
#   description     = "Handles nodes in the Dynamodb Stream"
#   dead_letter_arn = local.lambda_dead_letter_arn

#   environment_variables = {
#     ARTIFACTS_BUCKET_PREFIX        = local.artifacts_bucket_prefix
#     AUDIT_FIREHOSE                 = aws_kinesis_firehose_delivery_stream.process_audit_record_firehose.name
#     DYNAMODB_TABLE                 = module.graph_table.name
#     ENVIRONMENT                    = var.resource_prefix
#     ID_TOKEN_KEY                   = local.id_token_key
#     INTERNAL_APPSYNC_ROLES         = local.internal_appsync_role_names
#     LAMBDA_ROLE_ARN                = aws_iam_role.tenant_function.arn
#     LOG_LEVEL                      = "INFO"
#     MANAGED_APP_ROLE               = aws_iam_role.authenticated.arn
#     ROUTER_NODE_ARTIFACT           = local.lambda_functions_keys["router_node"]
#     TRANS_NODE_ARTIFACT            = local.lambda_functions_keys["trans_node"]
#     X_TENANT_SENDING_NODE_ARTIFACT = local.lambda_functions_keys["trans_node"]
#   }

#   handler     = "function.handler"
#   kms_key_arn = local.lambda_env_vars_kms_key_arn

#   memory_size = 1536
#   name        = "${var.resource_prefix}-graph-table-manage-nodes"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_nodes.arn,
#     aws_iam_policy.additional_ddb_policy.arn
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_nodes"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_nodes" {
#   name            = "${var.resource_prefix}-graph-table-manage-nodes"
#   log_group_name  = module.graph_table_manage_nodes.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }

# ################################
# ## graph-table-manage-tenants ##
# ################################
# data "aws_iam_policy_document" "graph_table_manage_tenants" {
#   statement {
#     actions = [
#       "appsync:GetGraphqlApi",
#       "appsync:GraphQL",
#     ]

#     resources = [
#       aws_appsync_graphql_api.echostream.arn,
#       "${aws_appsync_graphql_api.echostream.arn}/types/Mutation/fields/*",
#     ]

#     sid = "AppSync"
#   }

#   statement {
#     actions = [
#       "lambda:DeleteEventSourceMapping",
#       "lambda:GetEventSourceMapping",
#       "lambda:GetFunctionConfiguration",
#       "lambda:ListEventSourceMappings",
#       "lambda:UpdateFunctionConfiguration",
#       "lambda:DeleteFunction",
#       "lambda:CreateFunction"
#     ]

#     resources = [
#       "*",
#     ]

#     sid = "LambdaAccess"
#   }

#   statement {
#     effect = "Deny"

#     actions = [
#       "lambda:DeleteFunction",
#     ]

#     resources = [
#       "arn:aws:lambda:${local.current_region}:${data.aws_caller_identity.current.account_id}:function:echo-dev-*"
#     ]

#     sid = "DenyDeletingControlFunctions"
#   }

#   statement {
#     actions = [
#       "lambda:DeleteEventSourceMapping",
#       "lambda:ListEventSourceMappings",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "LambdaEventSourceMappings"
#   }

#   statement {
#     actions = [
#       "sqs:DeleteQueue",
#       "sqs:GetQueueAttributes",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "DeleteQueue"
#   }

#   statement {
#     effect = "Deny"

#     actions = [
#       "sqs:DeleteQueue",
#     ]

#     resources = [
#       aws_sqs_queue.system_sqs_queue.arn
#     ]

#     sid = "DoNotDeleteDefaultTenantQueue"
#   }


#   statement {
#     actions = [
#       "dynamodb:BatchWriteItem",
#       "dynamodb:Query",
#       "dynamodb:GetItem",
#       "dynamodb:DeleteItem",
#       "dynamodb:UpdateItem",
#     ]

#     resources = [
#       module.graph_table.arn,
#       "${module.graph_table.arn}/index/*",
#     ]

#     sid = "TableAccess"
#   }

#   statement {
#     actions = [
#       "kms:ScheduleKeyDeletion",
#     ]

#     resources = [
#       "*",
#     ]

#     sid = "KMS"
#   }

#   statement {
#     actions = [
#       "cognito-idp:AdminUserGlobalSignOut",
#       "cognito-idp:ListUsers",
#     ]

#     resources = [
#       aws_cognito_user_pool.echostream_ui.arn
#     ]

#     sid = "Cognito"
#   }

#   statement {
#     actions = [
#       "sns:DeleteTopic"
#     ]

#     resources = [
#       "*"
#     ]
#   }

#   statement {
#     actions = [
#       "cloudwatch:DeleteAlarms",
#     ]

#     resources = [
#       "*"
#     ]
#   }

#   statement {
#     actions = [
#       "sqs:GetQueueAttributes",
#     ]

#     resources = [
#       "*"
#     ]
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_tenants" {
#   description = "IAM permissions required for graph-table-manage-tenants"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-tenants"
#   policy      = data.aws_iam_policy_document.graph_table_manage_tenants.json
# }

# module "graph_table_manage_tenants" {
#   description     = "Creates/removes tenants and their AWS resources"
#   dead_letter_arn = local.lambda_dead_letter_arn

#   environment_variables = {
#     DYNAMODB_TABLE            = module.graph_table.name
#     DYNAMODB_TRIGGER_FUNCTION = module.graph_table_dynamodb_trigger.arn
#     ENVIRONMENT               = var.resource_prefix
#     INTERNAL_APPSYNC_ROLES    = local.internal_appsync_role_names
#     LOG_LEVEL                 = "INFO"
#     STREAM_HANDLER_FUNCTION   = module.graph_table_tenant_stream_handler.arn
#     TENANT_STREAM_HANDLER     = module.graph_table_tenant_stream_handler.arn
#     UI_USER_POOL_ID           = aws_cognito_user_pool.echostream_ui.id
#   }

#   handler     = "function.handler"
#   kms_key_arn = local.lambda_env_vars_kms_key_arn

#   memory_size = 1536
#   name        = "${var.resource_prefix}-graph-table-manage-tenants"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_tenants.arn,
#     aws_iam_policy.additional_ddb_policy.arn
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_tenants"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_tenants" {
#   name            = "${var.resource_prefix}-graph-table-manage-tenants"
#   log_group_name  = module.graph_table_manage_tenants.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }

# ##############################
# ## graph-table-manage-edges ##
# ##############################
# data "aws_iam_policy_document" "graph_table_manage_edges" {
#   statement {
#     actions = [
#       "sqs:DeleteQueue",
#       "sqs:GetQueueAttributes",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "DeleteQueue"
#   }

#   statement {
#     effect = "Deny"

#     actions = [
#       "sqs:DeleteQueue",
#     ]

#     resources = [
#       aws_sqs_queue.system_sqs_queue.arn
#     ]

#     sid = "DoNotDeleteDefaultTenantQueue"
#   }

#   statement {
#     actions = [
#       "cloudwatch:PutMetricAlarm",
#       "cloudwatch:DeleteAlarms",
#     ]

#     resources = [
#       "*"
#     ]
#   }

#   statement {
#     actions = [
#       "dynamodb:GetItem",
#       "dynamodb:DeleteItem",
#     ]
#     resources = [
#       module.graph_table.arn,
#     ]

#     sid = "ReadTable"
#   }

#   statement {
#     actions = [
#       "lambda:CreateEventSourceMapping",
#       "lambda:GetEventSourceMapping",
#       "lambda:GetFunctionConfiguration",
#       "lambda:ListEventSourceMappings",
#       "lambda:DeleteEventSourceMapping",
#       "lambda:UpdateFunctionConfiguration",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "LambdaEventSourceMappings"
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_edges" {
#   description = "IAM permissions required for graph-table-manage-edges"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-edges"
#   policy      = data.aws_iam_policy_document.graph_table_manage_edges.json
# }

# module "graph_table_manage_edges" {
#   description     = "Manage edges in db stream"
#   dead_letter_arn = local.lambda_dead_letter_arn

#   environment_variables = {
#     DYNAMODB_TABLE         = module.graph_table.name
#     ENVIRONMENT            = var.resource_prefix
#     INTERNAL_APPSYNC_ROLES = local.internal_appsync_role_names
#   }

#   handler     = "function.handler"
#   kms_key_arn = local.lambda_env_vars_kms_key_arn

#   memory_size = 1536
#   name        = "${var.resource_prefix}-graph-table-manage-edges"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_edges.arn,
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_edges"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_edges" {
#   name            = "${var.resource_prefix}-graph-table-manage-edges"
#   log_group_name  = module.graph_table_manage_edges.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }

# #################################
# ## graph-table-manage-kms-keys ##
# #################################
# data "aws_iam_policy_document" "graph_table_manage_kms_keys" {
#   statement {
#     actions = [
#       "kms:ScheduleKeyDeletion",
#     ]
#     resources = [
#       "*"
#     ]

#     sid = "KMSDeletion"
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_kms_keys" {
#   description = "IAM permissions required for graph-table-manage-kms-keys"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-kms-keys"
#   policy      = data.aws_iam_policy_document.graph_table_manage_kms_keys.json
# }

# module "graph_table_manage_kms_keys" {
#   description     = "Manage kms keys on dynamodb stream"
#   dead_letter_arn = local.lambda_dead_letter_arn

#   environment_variables = {
#     DYNAMODB_TABLE         = module.graph_table.name
#     ENVIRONMENT            = var.resource_prefix
#     INTERNAL_APPSYNC_ROLES = local.internal_appsync_role_names
#   }

#   handler     = "function.handler"
#   kms_key_arn = local.lambda_env_vars_kms_key_arn
#   memory_size = 1536
#   name        = "${var.resource_prefix}-graph-table-manage-kms-keys"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_kms_keys.arn,
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_kms_keys"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_kms_keys" {
#   name            = "${var.resource_prefix}-graph-table-manage-kms-keys"
#   log_group_name  = module.graph_table_manage_kms_keys.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }

# ##################################
# ## graph-table-manage-functions ##
# ##################################
# data "aws_iam_policy_document" "graph_table_manage_functions" {
#   statement {
#     actions = [
#       "dynamodb:Query",
#       "dynamodb:UpdateItem",
#     ]

#     resources = [
#       module.graph_table.arn,
#     ]

#     sid = "TableAccess"
#   }
#   statement {
#     actions = [
#       "lambda:GetFunctionConfiguration",
#       "lambda:UpdateFunctionConfiguration",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "LambdaEventSourceMappings"
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_functions" {
#   description = "IAM permissions required for graph-table-manage-functions"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-functions"
#   policy      = data.aws_iam_policy_document.graph_table_manage_functions.json
# }

# module "graph_table_manage_functions" {
#   description     = "manages functions in the Dynamodb Stream"
#   dead_letter_arn = local.lambda_dead_letter_arn

#   environment_variables = {
#     DYNAMODB_TABLE         = module.graph_table.name
#     ENVIRONMENT            = var.resource_prefix
#     INTERNAL_APPSYNC_ROLES = local.internal_appsync_role_names
#     LOG_LEVEL              = "INFO"
#   }

#   handler     = "function.handler"
#   kms_key_arn = local.lambda_env_vars_kms_key_arn

#   memory_size = 1536
#   name        = "${var.resource_prefix}-graph-table-manage-functions"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_functions.arn,
#     aws_iam_policy.additional_ddb_policy.arn,
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_functions"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_functions" {
#   name            = "${var.resource_prefix}-graph-table-manage-functions"
#   log_group_name  = module.graph_table_manage_functions.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }

# ##################################
# ## graph-table-manage-authorizations ##
# ##################################
# data "aws_iam_policy_document" "graph_table_manage_authorizations" {
#   statement {
#     actions = [
#       "dynamodb:PutItem",
#       "dynamodb:Query",
#       "dynamodb:UpdateItem",
#     ]

#     resources = [
#       module.graph_table.arn,
#     ]

#     sid = "TableAccess"
#   }

#   statement {
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]

#     resources = [
#       "*"
#     ]

#     sid = "LogsAccess"
#   }

#   statement {
#     actions = [
#       "cognito-idp:AdminGetUser",
#     ]

#     resources = [aws_cognito_user_pool.echostream_apps.arn]

#     sid = "AdminGetUser"
#   }
# }

# resource "aws_iam_policy" "graph_table_manage_authorizations" {
#   description = "IAM permissions required for graph-table-manage-authorizations"
#   path        = "/${var.resource_prefix}-lambda/"
#   name        = "${var.resource_prefix}-graph-table-manage-authorizations"
#   policy      = data.aws_iam_policy_document.graph_table_manage_authorizations.json
# }

# module "graph_table_manage_authorizations" {
#   description     = "Manages what principals are allowed to authorize an item"
#   dead_letter_arn = local.lambda_dead_letter_arn

#   environment_variables = {
#     DYNAMODB_TABLE         = module.graph_table.name
#     ENVIRONMENT            = var.resource_prefix
#     INTERNAL_APPSYNC_ROLES = local.internal_appsync_role_names
#     LOG_LEVEL              = "INFO"
#     MANAGED_APP_ROLE       = aws_iam_role.authenticated.arn
#     NODE_FUNCTION_ROLE     = aws_iam_role.tenant_function.arn
#     USER_POOL_ID           = aws_cognito_user_pool.echostream_apps.id
#   }

#   handler     = "function.handler"
#   kms_key_arn = local.lambda_env_vars_kms_key_arn

#   memory_size = 1536
#   name        = "${var.resource_prefix}-graph-table-manage-authorizations"

#   policy_arns = [
#     aws_iam_policy.graph_table_manage_authorizations.arn,
#     aws_iam_policy.additional_ddb_policy.arn,
#   ]

#   runtime       = "python3.9"
#   s3_bucket     = local.artifacts_bucket
#   s3_object_key = local.lambda_functions_keys["graph_table_manage_authorizations"]
#   source        = "QuiNovas/lambda/aws"
#   tags          = local.tags
#   timeout       = 300
#   version       = "3.0.14"
# }

# resource "aws_cloudwatch_log_subscription_filter" "graph_table_manage_authorizations" {
#   name            = "${var.resource_prefix}-graph-table-manage-authorizations"
#   log_group_name  = module.graph_table_manage_authorizations.log_group_name
#   filter_pattern  = "ERROR -USERERROR"
#   destination_arn = module.control_alert_handler.arn
# }