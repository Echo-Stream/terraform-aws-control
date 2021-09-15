resource "aws_sns_topic" "alarms" {
  name         = "${var.resource_prefix}-alarms"
  display_name = "${var.resource_prefix} Alarms"
  tags         = local.tags
}

resource "aws_sns_topic_policy" "alarms" {
  arn    = aws_sns_topic.alarms.arn
  policy = data.aws_iam_policy_document.alarms_sns_topic.json
}

data "aws_iam_policy_document" "alarms_sns_topic" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.alarms.arn]
  }
}

## US-EAST-1
module "alarm_distribution_us_east_1" {
  account_id          = data.aws_caller_identity.current.account_id
  alarm_sns_topic_arn = aws_sns_topic.alarms.arn
  name                = "${var.resource_prefix}-alarm-distribution"
  tags                = local.tags

  providers = {
    aws = aws.north-virginia
  }
  source = "./_modules/alarm-distributions"
}

## US-EAST-2
module "alarm_distribution_us_east_2" {
  account_id          = data.aws_caller_identity.current.account_id
  alarm_sns_topic_arn = aws_sns_topic.alarms.arn
  name                = "${var.resource_prefix}-alarm-distribution"
  tags                = local.tags

  providers = {
    aws = aws.ohio
  }

  source = "./_modules/alarm-distributions"
}

## US-WEST-1
module "alarm_distribution_" {
  account_id          = data.aws_caller_identity.current.account_id
  alarm_sns_topic_arn = aws_sns_topic.alarms.arn
  name                = "${var.resource_prefix}-alarm-distribution"
  tags                = local.tags

  providers = {
    aws = aws.north-california
  }

  source = "./_modules/alarm-distributions"
}
## ^ Should be done for supported regions

# ## IAM Roles
# ## Error Handler ##
# resource "aws_iam_role" "error_handler_role" {
#   name               = "${var.resource_prefix}-error-handler"
#   assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
#   tags               = local.tags
# }

# resource "aws_iam_role_policy_attachment" "error_handler_role_basic" {
#   role       = aws_iam_role.error_handler_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# data "aws_iam_policy_document" "error_handler_role" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "sns:Publish"
#     ]

#     resources = ["*"]

#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "kms:Decrypt",
#       "kms:GenerateDataKey",
#     ]

#     resources = ["*"]
#   }
# }

# resource "aws_iam_policy" "error_handler_role" {
#   description = "IAM permissions required for Node Error Publisher functions"
#   path        = "/${var.resource_prefix}-lambda/"
#   policy      = data.aws_iam_policy_document.error_handler_role.json
# }

# resource "aws_iam_role_policy_attachment" "error_handler_role" {
#   role       = aws_iam_role.error_handler_role.name
#   policy_arn = aws_iam_policy.error_handler_role.arn
# }

# ## Alert Handler ##
# resource "aws_iam_role" "alert_handler_role" {
#   name               = "${var.resource_prefix}-bndler"
#   assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
#   tags               = local.tags
# }

# resource "aws_iam_role_policy_attachment" "alert_handler_role_basic" {
#   role       = aws_iam_role.alert_handler_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# data "aws_iam_policy_document" "alert_handler_role" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "sns:Publish"
#     ]

#     resources = ["*"]

#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "lambda:GetFunction"
#     ]

#     resources = ["*"]

#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "kms:Decrypt",
#       "kms:GenerateDataKey",
#     ]

#     resources = ["*"]
#   }
#   statement {
#     effect = "Allow"

#     actions = [
#       "dynamodb:Query"
#     ]

#     resources = ["*"]

#   }
# }

# resource "aws_iam_policy" "alert_handler_role" {
#   description = "IAM permissions required for Node alert Publisher functions"
#   path        = "/${var.resource_prefix}-lambda/"
#   policy      = data.aws_iam_policy_document.alert_handler_role.json
# }

# resource "aws_iam_role_policy_attachment" "alert_handler_role" {
#   role       = aws_iam_role.alert_handler_role.name
#   policy_arn = aws_iam_policy.alert_handler_role.arn
# }

# ## Alarm Handler ##
# resource "aws_iam_role" "alarm_handler_role" {
#   name               = "${var.resource_prefix}-alarm-handler"
#   assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
#   tags               = local.tags
# }

# resource "aws_iam_role_policy_attachment" "alarm_handler_role_basic" {
#   role       = aws_iam_role.alarm_handler_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# data "aws_iam_policy_document" "alarm_handler_role" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "lambda:InvokeFunction"
#     ]

#     resources = ["*"]

#   }
# }

# resource "aws_iam_policy" "alarm_handler_role" {
#   description = "IAM permissions required for Node alarm Publisher functions"
#   path        = "/${var.resource_prefix}-lambda/"
#   policy      = data.aws_iam_policy_document.alarm_handler_role.json
# }

# resource "aws_iam_role_policy_attachment" "alarm_handler_role" {
#   role       = aws_iam_role.alarm_handler_role.name
#   policy_arn = aws_iam_policy.alarm_handler_role.arn
# }
