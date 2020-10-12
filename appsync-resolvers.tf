# We are using custom local exec resolvers,
# as aws_appsync_resolver TF resource is behind.
# TF resource doesn't support optional templates yet.

data "template_file" "resolver_sh" {
  template = file("${path.module}/scripts/resolvers.sh.tpl")
  vars = {
    api_id                  = aws_appsync_graphql_api.hl7_ninja.id
    tenant_datasource       = module.tenant_datasource.datasource_name
    message_type_datasource = module.message_type_datasource.datasource_name
  }
}

resource "null_resource" "all_resolvers" {
  depends_on = [
    null_resource.install_aws_cli,
    data.template_file.resolver_sh,
    module.tenant_datasource,
    module.message_type_datasource
  ]

  provisioner "local-exec" {
    command = "./ ${data.template_file.resolver_sh.rendered}"
  }
}
