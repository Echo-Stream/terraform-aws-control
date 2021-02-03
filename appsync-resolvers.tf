# We are using custom local exec resolvers,
# as aws_appsync_resolver TF resource is behind.
# TF resource doesn't support optional templates yet.
# https://github.com/terraform-providers/terraform-provider-aws/issues/15593

data "template_file" "resolver_sh" {
  template = file("${path.module}/scripts/resolvers.sh")
  vars = {
    api_id                           = aws_appsync_graphql_api.echostream.id
    api_user_datasource              = module.api_user_datasource.name
    app_datasource                   = module.app_datasource.name
    edge_datasource                  = module.appsync_edge_lambda_datasource.name
    function_datasource              = module.function_datasource.name
    kms_key_datasource               = module.appsync_kms_key_lambda_datasource.name
    large_message_storage_datasource = module.large_message_storage_datasource.name
    message_type_datasource          = module.message_type_datasource.name
    node_datasource                  = module.node_datasource.name
    sub_field_datasource             = module.sub_field_datasource.name
    subscription_datasource          = module.subscription_datasource.name
    templates_path                   = "${path.module}/files/response-template.vtl"
    tenant_datasource                = module.tenant_datasource.name
    validate_function_datasource     = module.validate_function_datasource.name
  }
}

resource "null_resource" "all_resolvers" {
  depends_on = [
    data.template_file.resolver_sh,
    module.api_user_datasource.name,
    module.appsync_edge_lambda_datasource,
    module.appsync_kms_key_lambda_datasource,
    module.function_datasource,
    module.large_message_storage_datasource,
    module.message_type_datasource,
    module.node_datasource,
    module.sub_field_datasource,
    module.subscription_datasource,
    module.tenant_datasource,
    module.validate_function_datasource,
  ]

  provisioner "local-exec" {
    command = "./ ${data.template_file.resolver_sh.rendered}"
  }
  triggers = {
    api_id                           = aws_appsync_graphql_api.echostream.id
    api_user_datasource              = module.api_user_datasource.name
    app_datasource                   = module.app_datasource.name
    deploy                           = data.template_file.resolver_sh.rendered
    edge_datasource                  = module.appsync_edge_lambda_datasource.name
    function_datasource              = module.function_datasource.name
    large_message_storage_datasource = module.large_message_storage_datasource.name
    message_type_datasource          = module.message_type_datasource.name
    node_datasource                  = module.node_datasource.name
    sub_field_datasource             = module.sub_field_datasource.name
    templates_path                   = "${path.module}/files/response-template.vtl"
    tenant_datasource                = module.tenant_datasource.name
    validate_function_datasource     = module.validate_function_datasource.name
  }
}
