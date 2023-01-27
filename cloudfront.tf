resource "aws_cloudfront_distribution" "webapp" {
  aliases = [
    local.app_sub_domain
  ]

  origin {
    domain_name = "${local.artifacts_bucket}.s3.amazonaws.com"
    origin_id   = "${var.resource_prefix}-webapp"
    origin_path = "/${var.echostream_version}/ui/app"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
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

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.resource_prefix} Echo Stream ReactJS Webapp"
}

## Origin Request Lambda, listening on path /config/config.json

data "template_file" "edge_config" {
  template = file("${path.module}/scripts/edge-config.py")
  vars = {
    billing_enabled  = local.billing_enabled != "" ? "True" : "False"
    client_id        = aws_cognito_user_pool_client.echostream_ui_userpool_client.id
    graphql_endpoint = local.appsync_custom_url
    region           = data.aws_region.current.name
    user_pool_id     = aws_cognito_user_pool.echostream_ui.id
  }
}

data "archive_file" "edge_config" {
  type        = "zip"
  output_path = "${path.module}/edge-config.zip"

  source {
    content  = data.template_file.edge_config.rendered
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
    domain_name = "${local.artifacts_bucket}.s3.amazonaws.com"
    origin_id   = "${var.resource_prefix}-api-docs"
    origin_path = "/${var.echostream_version}/ui/docs"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.docs_origin_access_identity.cloudfront_access_identity_path
    }
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

resource "aws_cloudfront_origin_access_identity" "docs_origin_access_identity" {
  comment = "${var.resource_prefix} Echo Stream API docs"
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