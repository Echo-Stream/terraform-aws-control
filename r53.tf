data "aws_route53_zone" "domain" {
  name = var.domain_name
}

resource "aws_route53_record" "webapp_cloudfront" {
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.webapp.domain_name
    zone_id                = aws_cloudfront_distribution.webapp.hosted_zone_id
  }

  name    = var.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id
}