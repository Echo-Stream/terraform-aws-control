resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${local.artifacts_bucket}.s3.amazonaws.com"
    origin_id   = "${local.environment_prefix}-webapp"
    origin_path = "/${var.hl7_ninja_version}/reactjs"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.environment_prefix} HL7 Ninja ReactJS Webapp"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.environment_prefix}-webapp"

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
    bucket          = local.log_bucket
    include_cookies = false
    prefix          = "cloudfront/${local.environment_prefix}-webapp/"
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
  comment = "${local.environment_prefix} HL7 Ninja ReactJS Webapp"
}