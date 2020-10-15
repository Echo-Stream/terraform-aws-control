resource "aws_cloudfront_distribution" "webapp" {
  origin {
    domain_name = "${local.artifacts_bucket}.s3.amazonaws.com"
    origin_id   = "${var.environment_prefix}-webapp"
    origin_path = "/${var.hl7_ninja_version}/reactjs"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.environment_prefix} HL7 Ninja ReactJS Webapp"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.environment_prefix}-webapp"

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
    target_origin_id = "${var.environment_prefix}-webapp"

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
    prefix          = "cloudfront/${var.environment_prefix}-webapp/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.environment_prefix} HL7 Ninja ReactJS Webapp"
}

## Origin Request Lambda, listening on path /config/config.json

data "template_file" "edge_config" {
  template = file("${path.module}/scripts/edge-config.py.tpl")
  vars = {
    graphql_endpoint = aws_appsync_graphql_api.hl7_ninja.uris["GRAPHQL"]
    client_id        = aws_cognito_user_pool_client.hl7_ninja_ui_userpool_client.id
    region           = local.current_region
    user_pool_id     = aws_cognito_user_pool.hl7_ninja_ui.id
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
  name               = "${var.environment_prefix}-edge-config"
  tags               = local.tags
}

resource "aws_lambda_function" "edge_config" {
  depends_on = [
    data.archive_file.edge_config
  ]

  description      = "Returns an environment specific config for reactjs application"
  filename         = "edge-config.zip"
  function_name    = "${var.environment_prefix}-edge-config"
  handler          = "function.lambda_handler"
  publish          = true
  role             = aws_iam_role.edge_config.arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.edge_config.output_base64sha256
  tags             = local.tags
  provider         = aws.us-east-1
}

resource "aws_lambda_permission" "edge_config" {
  provider      = aws.us-east-1
  action        = "lambda:GetFunction"
  function_name = aws_lambda_function.edge_config.function_name
  principal     = "edgelambda.amazonaws.com"
  statement_id  = "AllowExecutionFromCloudFront"
}