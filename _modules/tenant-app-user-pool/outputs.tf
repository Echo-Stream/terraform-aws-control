# output "arn" {
#   description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
#   value       = aws_s3_bucket.bucket.arn
# }

# output "id" {
#   description = "The name of the bucket."
#   value       = aws_s3_bucket.bucket.id
# }

# output "sns_topic_arn" {
#   description = "The ARN of the SNS topics"
#   value       = { for k, v in aws_sns_topic.sns : k => v.arn }
# }