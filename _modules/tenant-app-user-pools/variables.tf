variable "control_region" {
  description = "Control region name, e.g us-east-1"
  type        = string
}

variable "resource_prefix" {
  default     = []
  description = "A list of users/customers (normally root users) that can access the artifact bucket across accounts."
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = "Key-value map of tags"
  type        = map(string)
}

# variable "working_version" {
#   description = "Allows Bucket policy/Notifications to allow only specific versions"
#   type        = string
# }

variable "graph_table_name" {
  description = "Graph table name"
  type        = string
}

variable "tenant_regions" {
  description = "Json encoded list of tenant regions"
  type        = []
}

variable "artifacts_bucket" {
  description = "Artifacts bucket name"
  type = string
}

variable "name" {
  description = "Name that will be prefixed to the resource name"
  type        = string
}