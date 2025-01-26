resource "aws_cloudfront_origin_access_control" "default" {
  description                       = "${var.resource_prefix} Default origin access control"
  name                              = "${var.resource_prefix}-default"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#########################
### WebApp Cloudfront ###
#########################
resource "aws_cloudfront_distribution" "webapp" {
  aliases = [
    local.app_sub_domain
  ]

  origin {
    domain_name              = "${local.artifacts_bucket}.s3.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = "${var.resource_prefix}-webapp"
    origin_path              = "/${var.echostream_version}/ui/app"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.resource_prefix} Echo Stream ReactJS Webapp"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.resource_prefix}-webapp"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    path_pattern     = "/config/config.json"
    target_origin_id = "${var.resource_prefix}-webapp"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = aws_lambda_function.edge_config.qualified_arn
    }
  }

  logging_config {
    bucket          = data.aws_s3_bucket.log_bucket.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront/${var.resource_prefix}-webapp/"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.app.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.tags
}

## Origin Request Lambda, listening on path /config/config.json

data "archive_file" "edge_config" {
  type        = "zip"
  output_path = "${path.module}/edge-config.zip"

  source {
    content = templatefile(
      "${path.module}/scripts/edge-config.py",
      {
        billing_enabled          = var.billing_enabled ? "True" : "False"
        client_id                = aws_cognito_user_pool_client.echostream_ui_userpool_client.id
        graphql_endpoint         = local.appsync_custom_url
        paddle_client_side_token = var.paddle_client_side_token
        paddle_environment       = var.environment == "prod" ? "production" : "sandbox"
        region                   = data.aws_region.current.name
        user_pool_id             = aws_cognito_user_pool.echostream_ui.id
      }
    )
    filename = "function.py"
  }
}

resource "aws_iam_role" "edge_config" {
  assume_role_policy = data.aws_iam_policy_document.edge_lambda_assume_role.json
  name               = "${var.resource_prefix}-edge-config"
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "edge_config" {
  role       = aws_iam_role.edge_config.name
  policy_arn = data.aws_iam_policy.aws_lambda_basic_execution_role.arn
}

resource "aws_lambda_function" "edge_config" {
  description      = "Edge Lambda that returns an environment specific config for reactjs application"
  filename         = data.archive_file.edge_config.output_path
  function_name    = "${var.resource_prefix}-edge-config"
  handler          = "function.lambda_handler"
  publish          = true
  role             = aws_iam_role.edge_config.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.edge_config.output_base64sha256
  tags             = local.tags
  timeout          = 30

  provider = aws.us-east-1 ## currently Edge functions are supported in us-east-1 only
}

resource "aws_lambda_permission" "edge_config" {
  provider      = aws.us-east-1
  action        = "lambda:GetFunction"
  function_name = aws_lambda_function.edge_config.function_name
  principal     = "edgelambda.amazonaws.com"
  statement_id  = "AllowExecutionFromCloudFront"
}

module "webapp" {
  domain_name = aws_cloudfront_distribution.webapp.domain_name
  name        = local.app_sub_domain
  zone_id     = data.aws_route53_zone.root_domain.zone_id

  source  = "QuiNovas/cloudfront-r53-alias-record/aws"
  version = "0.0.2"

  providers = {
    aws = aws.route-53
  }
}

################################
### Documentation Cloudfront ###
################################
resource "aws_cloudfront_distribution" "docs" {
  aliases = [
    local.docs_api_sub_domain
  ]

  origin {
    domain_name              = "${local.artifacts_bucket}.s3.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = "${var.resource_prefix}-api-docs"
    origin_path              = "/${var.echostream_version}/ui/docs"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.resource_prefix} Echo Stream API docs"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.resource_prefix}-api-docs"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  logging_config {
    bucket          = data.aws_s3_bucket.log_bucket.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront/${var.resource_prefix}-api-docs/"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.docs_api.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.tags
}

module "docs" {
  domain_name = aws_cloudfront_distribution.docs.domain_name
  name        = local.docs_api_sub_domain
  zone_id     = data.aws_route53_zone.root_domain.zone_id

  source  = "QuiNovas/cloudfront-r53-alias-record/aws"
  version = "0.0.2"

  providers = {
    aws = aws.route-53
  }
}

############################
### OS Images Cloudfront ###
############################
resource "aws_cloudfront_distribution" "os_images" {
  aliases = [
    local.os_images_sub_domain
  ]

  origin {
    domain_name              = "${local.artifacts_bucket}.s3.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = "${var.resource_prefix}-os-images"
    origin_path              = "/${var.echostream_version}/os-images"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.resource_prefix} Echo Stream OS Images"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.resource_prefix}-os-images"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  logging_config {
    bucket          = data.aws_s3_bucket.log_bucket.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront/${var.resource_prefix}-os-images/"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.os_images.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.tags
}

module "os_images" {
  domain_name = aws_cloudfront_distribution.os_images.domain_name
  name        = local.os_images_sub_domain
  zone_id     = data.aws_route53_zone.root_domain.zone_id

  source  = "QuiNovas/cloudfront-r53-alias-record/aws"
  version = "0.0.2"

  providers = {
    aws = aws.route-53
  }
}
