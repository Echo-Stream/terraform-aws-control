output "firehose_arn" {
  value = aws_kinesis_firehose_delivery_stream.audit_records.arn
}

output "firehose_name" {
  value = aws_kinesis_firehose_delivery_stream.audit_records.name
}

output "bucket_id" {
  value = aws_s3_bucket.audit_records.id
}

output "bucket_arn" {
  value = aws_s3_bucket.audit_records.arn
}