output "dead_letter_arn" {
  description = "The ARN of SNS topic that is used as dead letter for the lambdas"
  value       = aws_sns_topic.lambda_dead_letter.arn
}

output "lambda_environment_variables" {
  description = "KMS Key arn for encrypting lambda environment variables"
  value       = aws_kms_key.lambda_environment_variables.arn
}

