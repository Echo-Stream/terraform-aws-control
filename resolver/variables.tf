variable "api_id" {
  description = "The API ID for the GraphQL API"
  type        = string
}

variable "type" {
  description = "The type name from the schema defined in the GraphQL API"
  type        = string
}

variable "field" {
  description = "The field name from the schema defined in the GraphQL API"
  type        = string
}

variable "datasource_name" {
  description = "The name of the data source for which the resolver is being created"
  type        = string
}