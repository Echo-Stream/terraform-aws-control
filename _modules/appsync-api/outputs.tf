output "api_id" {
  description = "Appsync API ID"
  value       = aws_appsync_graphql_api.echostream.id
}

output "datasource_name" {
  description = "Datasource name"
  value       = aws_appsync_datasource.appsync_datasource_.name
}
