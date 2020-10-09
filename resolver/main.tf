resource "null_resource" "create_resolver" {
  depends_on = [null_resource.install_aws_cli]

  provisioner "local-exec" {
    command = "aws appsync create-resolver --api-id ${var.api_id} --type-name ${var.type} --field-name ${var.field} --data-source-name ${var.datasource_name}"
  }
}