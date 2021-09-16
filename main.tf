###############################
## General Account Resources ##
###############################
module "log_bucket" {
  name_prefix = var.resource_prefix
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.4"
}

resource "aws_sns_topic" "lambda_dead_letter" {
  display_name = "${var.resource_prefix}-lambda-dead-letter"
  name         = "${var.resource_prefix}-lambda-dead-letter"
  tags         = local.tags
}

resource "aws_kms_key" "lambda_environment_variables" {
  description         = "Lambda environment variable key for ${var.resource_prefix}"
  enable_key_rotation = true
}

resource "aws_kms_alias" "lambda_environment_variables" {
  name          = "alias/${var.resource_prefix}-lambda-environment-variables"
  target_key_id = aws_kms_key.lambda_environment_variables.key_id
}

## Regional Log buckets
module "log_bucket_us_east_1" {
  count       = contains(local.regions, "us-east-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-us-east-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.north-virginia
  }
}

module "log_bucket_us_east_2" {
  count       = contains(local.regions, "us-east-2") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-us-east-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ohio
  }
}

module "log_bucket_us_west_1" {
  count       = contains(local.regions, "us-west-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-us-west-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.north-california
  }
}

module "log_bucket_us_west_2" {
  count       = contains(local.regions, "us-west-2") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-us-west-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.oregon
  }
}

####
module "log_bucket_af_south_1" {
  count       = contains(local.regions, "af-south-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-af-south-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.cape-town
  }
}

####
module "log_bucket_ap_east_1" {
  count       = contains(local.regions, "ap-east-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-ap-east-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.hongkong
  }
}

module "log_bucket_ap_south_1" {
  count       = contains(local.regions, "ap-south-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-ap-south-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.mumbai
  }
}

module "log_bucket_ap_northeast_2" {
  count       = contains(local.regions, "ap-northeast-2") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-ap-northeast-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.osaka
  }
}

module "log_bucket_ap_southeast_1" {
  count       = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-ap-southeast-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.singapore
  }
}

module "log_bucket_ap_southeast_2" {
  count       = contains(local.regions, "ap-southeast-2") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-ap-southeast-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ap-southeast-2
  }
}

module "log_bucket_ap_northeast_1" {
  count       = contains(local.regions, "ap-northeast-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-ap-northeast-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ap-northeast-1
  }
}

####
module "log_bucket_ca_central_1" {
  count       = contains(local.regions, "ca-central-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-ca-central-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ca-central-1
  }
}

####
module "log_bucket_eu_central_1" {
  count       = contains(local.regions, "eu-central-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-eu-central-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-central-1
  }
}

module "log_bucket_eu_west_1" {
  count       = contains(local.regions, "eu-west-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-eu-west-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-west-1
  }
}

module "log_bucket_eu_west_2" {
  count       = contains(local.regions, "eu-west-2") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-eu-west-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-west-2
  }
}

module "log_bucket_eu_south_1" {
  count       = contains(local.regions, "eu-south-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-eu-south-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-south-1
  }
}

module "log_bucket_eu_west_3" {
  count       = contains(local.regions, "eu-west-3") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-eu-west-3"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-west-3
  }
}

module "log_bucket_eu_north_1" {
  count       = contains(local.regions, "eu-north-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-eu-north-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-north-1
  }
}

####
module "log_bucket_me_south_1" {
  count       = contains(local.regions, "me-south-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-me-south-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.me-south-1
  }
}

####
module "log_bucket_sa_east_1" {
  count       = contains(local.regions, "sa-east-1") == true ? 1 : 0
  name_prefix = "${var.resource_prefix}-sa-east-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.sa-east-1
  }
}

# ## Trigger Deployment
# resource "null_resource" "echo_deployment" {
#   depends_on = [
#     module.graph_table,
#     module.deployment_handler,
#     aws_appsync_graphql_api.echostream,
#     aws_cloudfront_distribution.webapp,
#   ]

#   triggers = {
#     version        = var.echostream_version
#     manual_trigger = var.manual_deployment_trigger
#   }

#   provisioner "local-exec" {
#     command = "aws lambda invoke --function-name ${module.deployment_handler.name} --invocation-type Event --payload '{\"trigger\": \"terraform\"}' response.json"
#   }
# }