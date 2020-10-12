resource "null_resource" "install_aws_cli" {

  provisioner "local-exec" {
    command = <<EOH
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "${path.module}/awscli-bundle.zip"; unzip ${path.module}/awscli-bundle.zip -d ${path.module}; ${path.module}/awscli-bundle/install -b ~/bin/aws;
EOH
  }

  triggers = {
    api_id = aws_appsync_graphql_api.hl7_ninja.id
    message_type_datasource = module.message_type_datasource.datasource_name
  }
}