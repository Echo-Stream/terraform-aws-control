resource "null_resource" "install_aws_cli" {

  provisioner "local-exec" {
    command = <<EOH
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "${path.module}/awscli-bundle.zip"; unzip ${path.module}/awscli-bundle.zip -d ${path.module}; ${path.module}/awscli-bundle/install -b ~/bin/aws;
EOH
  }

  triggers = {
    api_id                           = aws_appsync_graphql_api.hl7_ninja.id
    message_type_datasource          = module.message_type_datasource.name
    tenant_datasource                = module.tenant_datasource.name
    node_datasource                  = module.node_datasource.name
    edge_datasource                  = module.appsync_edge_lambda_datasource.name
    app_datasource                   = module.app_datasource.name
    validate_function_datasource     = module.validate_function_datasource.name
    sub_field_datasource             = module.sub_field_datasource.name
    large_message_storage_datasource = module.large_message_storage_datasource.name
  }
}