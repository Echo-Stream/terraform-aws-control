output "userpool_id" {
  description = "The ID of the APP cognito userpool"
  value       = aws_cognito_user_pool.echostream_app.id
}

output "userpool_arn" {
  description = "The ARN of the APP cognito userpool"
  value       = aws_cognito_user_pool.echostream_app.arn
}


output "client_id" {
  description = "The ID of the APP cognito userpool client"
  value       = aws_cognito_user_pool_client.echostream_app_userpool_client.id
}

