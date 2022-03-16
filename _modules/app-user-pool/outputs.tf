output "userpool_id" {
  description = "The ID of the APP cognito userpool"
  value       = aws_cognito_user_pool.echostream_app.id
}
