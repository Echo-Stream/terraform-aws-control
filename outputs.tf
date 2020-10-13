/*output "ses_domain_identity_arn" {
  value = aws_ses_domain_identity.hl7_ninja.arn
}

output "ses_domain_identity_id" {
  value = aws_ses_domain_identity.hl7_ninja.id
}

output "ses_domain_identity_verification_token" {
  value = aws_ses_domain_identity.hl7_ninja.verification_token
}

output "aws_ses_domain_dkim_tokens" {
  value = aws_ses_domain_dkim.hl7_ninja.dkim_tokens
}
*/

output "appsync_id" {
  value = aws_appsync_graphql_api.hl7_ninja.id
}

output "appsync_url" {
  value = aws_appsync_graphql_api.hl7_ninja.uris["GRAPHQL"]
}

output "apps_user_pool_id" {
  value = aws_cognito_user_pool.hl7_ninja_apps.id
}

output "apps_user_pool_arn" {
  value = aws_cognito_user_pool.hl7_ninja_apps.arn
}

output "apps_user_pool_endpoint" {
  value = aws_cognito_user_pool.hl7_ninja_apps.endpoint
}

output "apps_user_pool_client_id" {
  value = aws_cognito_user_pool_client.hl7_ninja_apps_userpool_client.id
}


output "ui_user_pool_id" {
  value = aws_cognito_user_pool.hl7_ninja_ui.id
}

output "ui_user_pool_arn" {
  value = aws_cognito_user_pool.hl7_ninja_ui.arn
}

output "ui_user_pool_endpoint" {
  value = aws_cognito_user_pool.hl7_ninja_ui.endpoint
}

output "ui_user_pool_client_id" {
  value = aws_cognito_user_pool_client.hl7_ninja_ui_userpool_client.id
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.hl7_ninja.id
}

output "identity_pool_arn" {
  value = aws_cognito_identity_pool.hl7_ninja.arn
}