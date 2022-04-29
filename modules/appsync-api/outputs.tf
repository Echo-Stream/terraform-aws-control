output "api_id" {
  description = "Appsync API ID"
  value       = aws_appsync_graphql_api.echostream.id
}

output "datasource_name" {
  description = "Datasource name"
  value       = aws_appsync_datasource.appsync_datasource_.name
}

output "appsync_domain_name" {
  description = "The domain name that AppSync provides"
  value       = aws_appsync_domain_name.echostream_appsync.appsync_domain_name
}