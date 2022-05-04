## Control Terraform
Terraform Module Control Resources. 

### Usage
```
module "control" {
  allowed_account_id                        = var.allowed_account_id
  authorized_domains                        = var.authorized_domains
  create_dynamo_db_replication_service_role = false
  domain_name                               = var.domain_name
  echostream_version                        = var.echostream_version
  environment                               = var.environment
  region                                    = var.region
  resource_prefix                           = "${var.resource_prefix}-${var.environment}"
  route53_account_id                        = var.route53_account_id
  route53_manager_role_name                 = var.route53_manager_role_name
  ses_email_address                         = var.ses_email_address
  tags                                      = local.tags
  tenant_regions                            = var.tenant_regions

  source = "app.terraform.io/EchoStream/control/aws"
}

```

### Important Note
- The SES email identity of the ses email address that is being passed as input should have been already ready to be used.