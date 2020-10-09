resource "null_resource" "install_aws_cli" {
  provisioner "local-exec" {
    command = <<EOH
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "${path.module}/awscli-bundle.zip" \
&& unzip ${path.module}/awscli-bundle.zip -d ${path.module} \
&& sudo ${path.module}/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
EOH
  }
}
