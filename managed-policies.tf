####################################
## Manage Graph Table - Read Only ##
####################################
data "aws_iam_policy_document" "graph_ddb_read" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "TableAccessRead"
  }

  statement {
    actions = [
      "dynamodb:Query"
    ]

    resources = [
      module.graph_table.arn,
      "${module.graph_table.arn}/index/*"
    ]

    sid = "TableAccessQuery"
  }
}

resource "aws_iam_policy" "graph_ddb_read" {
  description = "IAM permissions to read graph-table"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-graph-table-read"
  policy      = data.aws_iam_policy_document.graph_ddb_read.json
}

######################################
##### Manage Graph Table - Write #####
######################################
data "aws_iam_policy_document" "graph_ddb_write" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]

    resources = [
      module.graph_table.arn,
    ]

    sid = "WriteAccesstoTable"
  }
}

resource "aws_iam_policy" "graph_ddb_write" {
  description = "IAM permissions to write graph-table"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-graph-table-write"
  policy      = data.aws_iam_policy_document.graph_ddb_write.json
}

#################################
##### Artifacts Bucket Read #####
#################################
data "aws_iam_policy_document" "artifacts_bucket_read" {
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
}

resource "aws_iam_policy" "artifacts_bucket_read" {
  description = "IAM permissions to read Artifact Buckets"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-artifacts-bucket-read"
  policy      = data.aws_iam_policy_document.artifacts_bucket_read.json
}

#################################
## Tenant Table - Read & Write ##
#################################
data "aws_iam_policy_document" "tenant_table_read_write" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]

    resources = [
      "arn:aws:dynamodb:*:${local.current_account_id}:table/${var.resource_prefix}-tenant-*"
    ]

    sid = "TenantTableAccess"
  }
}

resource "aws_iam_policy" "tenant_table_read_write" {
  description = "IAM permissions to read and write Tenant tables"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-tenant-table-read-write"
  policy      = data.aws_iam_policy_document.tenant_table_read_write.json
}


################
## ECR - Read ##
################
data "aws_iam_policy_document" "ecr_read" {
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
}

resource "aws_iam_policy" "ecr_read" {
  description = "IAM permissions to get ECR images"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-ecr-read"
  policy      = data.aws_iam_policy_document.ecr_read.json
}

############################
### Graph table handlers ###
############################

data "aws_iam_policy_document" "graph_table_handler" {
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
      "ses:GetTemplate",
      "ses:ListTemplates"
    ]

    resources = [
      "*"
    ]

    sid = "SESRead"
  }


  statement {
    actions = [
      "ses:SendEmail",
    ]

    resources = [
      aws_ses_configuration_set.email_errors.arn,
      aws_ses_email_identity.support.arn,
    ]

    sid = "SESSendEmail"
  }

  statement {
    actions = [
      "ses:SendTemplatedEmail",
    ]

    resources = [
      aws_ses_configuration_set.email_errors.arn,
      aws_ses_email_identity.support.arn,
      aws_ses_template.invite_user.arn,
      aws_ses_template.notify_user.arn,
      aws_ses_template.remove_user.arn,
    ]

    sid = "SESSendTemplatedEmail"
  }

  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
    ]

    resources = [
      "arn:aws:sqs:*:${local.current_account_id}:db-stream*.fifo",
      aws_sqs_queue.system_sqs_queue.arn
    ]

    sid = "PrerequisitesForQueueTrigger"
  }

  statement {
    actions = [
      "sqs:DeleteQueue",
    ]

    resources = [
      "arn:aws:sqs:*:${local.current_account_id}:edge*.fifo",
      "arn:aws:sqs:*:${local.current_account_id}:db-stream*.fifo"
    ]

    sid = "DeleteQueue"
  }

  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
    ]

    resources = [
      aws_sqs_queue.rebuild_notifications.arn
    ]

    sid = "SendMessageToRebuildNotificationQueue"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteSubscriptionFilter",
      "logs:PutRetentionPolicy",
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      "arn:aws:logs:*:${local.current_account_id}:log-group:*"
    ]

    sid = "LogsAccess"
  }

  statement {
    actions = [
      "logs:Describe*",
    ]

    resources = [
      "*"
    ]

    sid = "LogsReadAccess"
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:${local.current_account_id}:log-group:*:log-stream:*"
    ]

    sid = "LogsEventsAccess"
  }


  statement {
    actions = [
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminUserGlobalSignOut",
      "cognito-idp:ListUsers",
    ]

    resources = [
      aws_cognito_user_pool.echostream_api.arn,
      aws_cognito_user_pool.echostream_ui.arn,
    ]

    sid = "AdminGetUser"
  }


  statement {
    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:ListGrants",
      "kms:RetireGrant",
      "kms:RevokeGrant",
      "kms:ScheduleKeyDeletion",
    ]

    resources = ["arn:aws:kms:*:${local.current_account_id}:key/*"]

    sid = "KMSPermissions"
  }

  statement {
    actions = [
      "kms:DeleteAlias",
    ]

    resources = ["arn:aws:kms:*:${local.current_account_id}:alias/*"]

    sid = "DeleteKMSAlias"
  }

  statement {
    actions = [
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:InvokeFunction",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "arn:aws:lambda:*:${local.current_account_id}:function:*Node*",
      "arn:aws:lambda:*:${local.current_account_id}:function:Validator*"
    ]

    sid = "LambdaAllAccess"
  }

  statement {
    actions = [
      "lambda:DeleteEventSourceMapping",
    ]

    resources = [
      "arn:aws:lambda:*:${local.current_account_id}:event-source-mapping:*"
    ]

    sid = "LambdaEventSourceMappings"
  }

  statement {
    actions = [
      "lambda:ListEventSourceMappings",
      "lambda:ListFunctions",
    ]

    resources = [
      "*"
    ]

    sid = "LambdaListAccess"
  }

  statement {
    actions = [
      "iam:PassRole",
    ]

    resources = [
      aws_iam_role.internal_node.arn
    ]

    sid = "TenantFunctionRoleIAM"
  }

  statement {
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
    ]

    resources = [
      "arn:aws:cloudwatch:*:${local.current_account_id}:alarm:TENANT~*"
    ]

    sid = "AccessTenantAlarms"
  }
}

resource "aws_iam_policy" "graph_table_handler" {
  description = "IAM permissions required for both graph table tenant and system handlers"
  path        = "/lambda/control/"
  name        = "${var.resource_prefix}-graph-table-tenant-system-handler"
  policy      = data.aws_iam_policy_document.graph_table_handler.json
}
