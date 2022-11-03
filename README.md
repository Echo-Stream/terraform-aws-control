## Control Terraform
Terraform Module Control Resources. 

### Usage
```
module "control" {
  authorized_domains                        = var.authorized_domains
  check_domains                             = true
  create_dynamo_db_replication_service_role = false
  domain_name                               = var.domain_name
  echostream_version                        = var.echostream_version
  environment                               = var.environment
  resource_prefix                           = "${var.resource_prefix}-${var.environment}"
  ses_email_address                         = var.ses_email_address
  tags                                      = local.tags
  tenant_regions                            = var.tenant_regions

  providers = {
    aws.route-53 = aws.route-53
  }

  source = "app.terraform.io/EchoStream/control/aws"
}

```

### Important Note
- The SES email identity of the ses email address that is being passed as input should have been already ready to be used.