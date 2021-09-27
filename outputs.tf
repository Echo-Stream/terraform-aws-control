/*output "ses_domain_identity_arn" {
  value = aws_ses_domain_identity.echostream.arn
}

output "ses_domain_identity_id" {
  value = aws_ses_domain_identity.echostream.id
}

output "ses_domain_identity_verification_token" {
  value = aws_ses_domain_identity.echostream.verification_token
}

output "aws_ses_domain_dkim_tokens" {
  value = aws_ses_domain_dkim.echostream.dkim_tokens
}
*/

output "appsync_id" {
  description = "Main API ID of the EchoStream"
  value       = aws_appsync_graphql_api.echostream.id
}

output "appsync_url" {
  description = "API URL of the EchoStream"
  value       = aws_appsync_graphql_api.echostream.uris["GRAPHQL"]
}

# output "apps_user_pool_id" {
#   description = "The ID of the apps cognito user pool"
#   value       = aws_cognito_user_pool.echostream_apps.id
# }

# output "apps_user_pool_arn" {
#   description = "The ARN of the apps cognito user pool"
#   value       = aws_cognito_user_pool.echostream_apps.arn
# }

# output "apps_user_pool_endpoint" {
#   description = "Endpoint of the apps cognito user pool"
#   value       = aws_cognito_user_pool.echostream_apps.endpoint
# }

output "apps_user_pool_client_id" {
  description = "The ID of the apps cognito user pool client"
  value       = aws_cognito_user_pool_client.echostream_apps_userpool_client.id
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

# output "identity_pool_id" {
#   description = "EchoStream Identity pool ID"
#   value       = aws_cognito_identity_pool.echostream.id
# }

# output "identity_pool_arn" {
#   description = "The ARN of the EchoStream identity pool"
#   value       = aws_cognito_identity_pool.echostream.arn
# }

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
  description = "EchoStream CloudFront distribution Domain name"
  value       = aws_cloudfront_distribution.webapp.domain_name
}