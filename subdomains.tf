locals {
  app_sub_domain      = var.environment == "prod" ? "app.${var.domain_name}" : "app-${var.environment}.${var.domain_name}"
  docs_api_sub_domain = var.environment == "prod" ? "docs.api.${var.domain_name}" : "docs.api-${var.environment}.${var.domain_name}"
}

#########
## SSL ##
#########

######### App ##########
resource "aws_acm_certificate" "app" {
  domain_name       = local.app_sub_domain
  validation_method = "DNS"
  tags              = var.tags

  provider = aws.us-east-1
}

resource "aws_route53_record" "app" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.root_domain.zone_id

  provider = aws.route-53
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.app : record.fqdn]

  provider = aws.us-east-1
}


######### DOCS API ##########
resource "aws_acm_certificate" "docs_api" {
  domain_name       = local.docs_api_sub_domain
  validation_method = "DNS"
  tags              = var.tags

  provider = aws.us-east-1
}

resource "aws_route53_record" "docs_api" {
  for_each = {
    for dvo in aws_acm_certificate.docs_api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.root_domain.zone_id

  provider = aws.route-53
}

resource "aws_acm_certificate_validation" "docs_api" {
  certificate_arn         = aws_acm_certificate.docs_api.arn
  validation_record_fqdns = [for record in aws_route53_record.docs_api : record.fqdn]

  provider = aws.us-east-1
}

######### appsync custom domain ##########
# Certifcates used for appsync domain must be always in us-east-1

resource "aws_acm_certificate" "regional_api" {
  for_each = toset(local.tenant_regions)

  domain_name       = "api-${var.environment}.${each.key}.${var.domain_name}"
  tags              = var.tags
  validation_method = "DNS"

  provider = aws.us-east-1
}

resource "aws_route53_record" "regional_api" {
  for_each = aws_acm_certificate.regional_api

  allow_overwrite = true
  name            = tolist(each.value.domain_validation_options)[0].resource_record_name
  records         = [tolist(each.value.domain_validation_options)[0].resource_record_value]
  ttl             = 60
  type            = tolist(each.value.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.root_domain.zone_id

  provider = aws.route-53
}

resource "aws_acm_certificate_validation" "regional_api" {
  for_each = aws_acm_certificate.regional_api

  certificate_arn         = each.value.arn
  validation_record_fqdns = [for record in aws_route53_record.regional_api : record.fqdn]

  provider = aws.us-east-1
}