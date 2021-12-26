output "appsync_id" {
  description = "Main API ID of the EchoStream"
  value       = aws_appsync_graphql_api.echostream.id
}

output "appsync_url" {
  description = "API URL of the EchoStream"
  value       = aws_appsync_graphql_api.echostream.uris["GRAPHQL"]
}

output "appsync_custom_url" {
  description = "Custom API URL of the EchoStream"
  value       = local.appsync_custom_url
}

output "ui_user_pool_id" {
  description = "The ID of the UI cognito user pool"
  value       = aws_cognito_user_pool.echostream_ui.id
}

output "ui_user_pool_arn" {
  description = "The ARN of the UI cognito user pool"
  value       = aws_cognito_user_pool.echostream_ui.arn
}

output "ui_user_pool_endpoint" {
  description = "Endpoint of the UI cognito user pool"
  value       = aws_cognito_user_pool.echostream_ui.endpoint
}

output "ui_user_pool_client_id" {
  description = "The ID of the UI cognito user pool client"
  value       = aws_cognito_user_pool_client.echostream_ui_userpool_client.id
}

output "api_user_pool_id" {
  description = "The ID of the API cognito user pool"
  value       = aws_cognito_user_pool.echostream_api.id
}

output "api_user_pool_arn" {
  description = "The ARN of the API cognito user pool"
  value       = aws_cognito_user_pool.echostream_api.arn
}

output "api_user_pool_endpoint" {
  description = "Endpoint of the API cognito user pool"
  value       = aws_cognito_user_pool.echostream_api.endpoint
}

output "api_user_pool_client_id" {
  description = "The ID of the API cognito user pool client"
  value       = aws_cognito_user_pool_client.echostream_api_userpool_client.id
}

## Cloudfront
output "cloudfront_oai_id" {
  description = "The identifier for the EchoStream CloudFront distribution"
  value       = aws_cloudfront_origin_access_identity.origin_access_identity.id
}

output "cloudfront_oai_iam_arn" {
  description = "EchoStream Cloudfront orgin access identity. Pre-generated ARN for use in S3 bucket policies"
  value       = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
}

output "cloudfront_domain_name" {
  description = "EchoStream CloudFront distribution Domain name to be added in to Route53"
  value       = aws_cloudfront_distribution.webapp.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "EchoStream CloudFront distribution Hosted Zone ID"
  value       = aws_cloudfront_distribution.webapp.hosted_zone_id
}