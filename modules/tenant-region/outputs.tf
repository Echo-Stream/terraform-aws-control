output "api_id" {
  description = "Appsync API ID"
  value       = aws_appsync_graphql_api.echostream.id
}

output "client_id" {
  description = "The ID of the APP cognito userpool client"
  value       = module.app_cognito_pool.client_id
}

output "dead_letter_arn" {
  description = "The ARN of SNS topic that is used as dead letter for the lambdas"
  value       = aws_sns_topic.lambda_dead_letter.arn
}

output "kms_key_arn" {
  description = "KMS Key arn for encrypting lambda environment variables"
  value       = aws_kms_key.lambda_environment_variables.arn
}

output "userpool_id" {
  description = "The ID of the APP cognito userpool"
  value       = module.app_cognito_pool.userpool_id
}
