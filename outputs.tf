output "api_user_pool_arn" {
  description = "The ARN of the API cognito user pool"
  value       = aws_cognito_user_pool.echostream_api.arn
}

output "api_user_pool_client_id" {
  description = "The ID of the API cognito user pool client"
  value       = aws_cognito_user_pool_client.echostream_api_userpool_client.id
}

output "api_user_pool_endpoint" {
  description = "Endpoint of the API cognito user pool"
  value       = aws_cognito_user_pool.echostream_api.endpoint
}

output "api_user_pool_id" {
  description = "The ID of the API cognito user pool"
  value       = aws_cognito_user_pool.echostream_api.id
}

output "cloudfront_domain_name_api_docs" {
  description = "EchoStream API Docs CloudFront distribution Domain name to be added in to Route53"
  value       = aws_cloudfront_distribution.docs.domain_name
}

output "cloudfront_domain_name_webapp" {
  description = "EchoStream Webapp CloudFront distribution Domain name to be added in to Route53"
  value       = aws_cloudfront_distribution.webapp.domain_name
}
output "cloudfront_hosted_zone_id" {
  description = "Standard CloudFront distribution Hosted Zone ID to be used in route53 for webapp and docs cloudfront records"
  value       = aws_cloudfront_distribution.webapp.hosted_zone_id
}

output "cloudfront_oai_iam_arn_api_docs" {
  description = "EchoStream API Docs Cloudfront origin access identity. Pre-generated ARN for use in S3 bucket policies"
  value       = aws_cloudfront_origin_access_identity.docs_origin_access_identity.iam_arn
}

output "cloudfront_oai_iam_arn_webapp" {
  description = "EchoStream Webapp Cloudfront origin access identity. Pre-generated ARN for use in S3 bucket policies"
  value       = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
}

output "cloudfront_oai_id_api_docs" {
  description = "The identifier for the EchoStream API Docs CloudFront distribution"
  value       = aws_cloudfront_origin_access_identity.docs_origin_access_identity.id
}
output "cloudfront_oai_id_webapp" {
  description = "The identifier for the EchoStream Webapp CloudFront distribution"
  value       = aws_cloudfront_origin_access_identity.origin_access_identity.id
}

output "log_bucket_id" {
  description = "The ID of the control region bucket"
  value       = module.log_bucket.id
}

output "regional_app_user_pool_client_ids" {
  description = "A map of all regional App userpool client ids"
  value       = local.app_user_pool_client_ids
}

output "regional_app_user_pool_ids" {
  description = "A map of all regional App userpool endpoints"
  value       = local.app_user_pool_ids
}

output "regional_appsync_endpoints" {
  description = "A map of regional appsync endpoints"
  value       = local.regional_appsync_endpoints
}

output "regional_appsync_ids" {
  description = "A map of regional appsync ids"
  value       = local.appsync_api_ids
}

output "ui_user_pool_arn" {
  description = "The ARN of the UI cognito user pool"
  value       = aws_cognito_user_pool.echostream_ui.arn
}

output "ui_user_pool_client_id" {
  description = "The ID of the UI cognito user pool client"
  value       = aws_cognito_user_pool_client.echostream_ui_userpool_client.id
}

output "ui_user_pool_endpoint" {
  description = "Endpoint of the UI cognito user pool"
  value       = aws_cognito_user_pool.echostream_ui.endpoint
}

output "ui_user_pool_id" {
  description = "The ID of the UI cognito user pool"
  value       = aws_cognito_user_pool.echostream_ui.id
}
