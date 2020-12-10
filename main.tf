###############################
## General Account Resources ##
###############################
module log_bucket {
  name_prefix = var.environment_prefix
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"
}

resource aws_sns_topic lambda_dead_letter {
  display_name = "${var.environment_prefix}-lambda-dead-letter"
  name         = "${var.environment_prefix}-lambda-dead-letter"
  tags         = local.tags
}

resource aws_kms_key lambda_environment_variables {
  description         = "Lambda environment variable key for ${var.environment_prefix}"
  enable_key_rotation = true
}

resource aws_kms_alias lambda_environment_variables {
  name          = "alias/${var.environment_prefix}-lambda-environment-variables"
  target_key_id = aws_kms_key.lambda_environment_variables.key_id
}

## Regional Log buckets
module log_bucket_us_east_1 {
  count       = contains(local.regions, "us-east-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-us-east-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.us-east-1
  }
}

module log_bucket_us_east_2 {
  count       = contains(local.regions, "us-east-2") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-us-east-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.us-east-2
  }
}

module log_bucket_us_west_1 {
  count       = contains(local.regions, "us-west-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-us-west-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.us-west-1
  }
}

module log_bucket_us_west_2 {
  count       = contains(local.regions, "us-west-2") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-us-west-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.us-west-2
  }
}

#####
module log_bucket_af_south_1 {
  count       = contains(local.regions, "af-south-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-af-south-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.af-south-1
  }
}

####
module log_bucket_ap_east_1 {
  count       = contains(local.regions, "ap-east-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-ap-east-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ap-east-1
  }
}

module log_bucket_ap_south_1 {
  count       = contains(local.regions, "ap-south-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-ap-south-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ap-south-1
  }
}

module log_bucket_ap_northeast_2 {
  count       = contains(local.regions, "ap-northeast-2") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-ap-northeast-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ap-northeast-2
  }
}

module log_bucket_ap_southeast_1 {
  count       = contains(local.regions, "ap-southeast-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-ap-southeast-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ap-southeast-1
  }
}

module log_bucket_ap_southeast_2 {
  count       = contains(local.regions, "ap-southeast-2") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-ap-southeast-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ap-southeast-2
  }
}

module log_bucket_ap_northeast_1 {
  count       = contains(local.regions, "ap-northeast-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-ap-northeast-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ap-northeast-1
  }
}

####
module log_bucket_ca_central_1 {
  count       = contains(local.regions, "ca-central-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-ca-central-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.ca-central-1
  }
}

####
module log_bucket_eu_central_1 {
  count       = contains(local.regions, "eu-central-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-eu-central-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-central-1
  }
}

module log_bucket_eu_west_1 {
  count       = contains(local.regions, "eu-west-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-eu-west-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-west-1
  }
}

module log_bucket_eu_west_2 {
  count       = contains(local.regions, "eu-west-2") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-eu-west-2"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-west-2
  }
}

module log_bucket_eu_south_1 {
  count       = contains(local.regions, "eu-south-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-eu-south-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-south-1
  }
}

module log_bucket_eu_west_3 {
  count       = contains(local.regions, "eu-west-3") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-eu-west-3"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-west-3
  }
}

module log_bucket_eu_north_1 {
  count       = contains(local.regions, "eu-north-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-eu-north-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.eu-north-1
  }
}

####
module log_bucket_me_south_1 {
  count       = contains(local.regions, "me-south-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-me-south-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.me-south-1
  }
}

####
module log_bucket_sa_east_1 {
  count       = contains(local.regions, "sa-east-1") == true ? 1 : 0
  name_prefix = "${var.environment_prefix}-sa-east-1"
  source      = "QuiNovas/log-bucket/aws"
  version     = "3.0.2"

  providers = {
    aws = aws.sa-east-1
  }
}
