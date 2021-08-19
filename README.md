## Control Terraform
Terraform Module for Echo Stream Control Resources

### Important Note
- Domain name and ACM certificate covering the domain Inputs are needed. These resources are created by Pre control TF.
- This module is supported in all US Regions except `US-WEST-1` region
- Verifying an email address provided to SES service is manual. User needs to verify a link that is sent by AWS SES to the provided email.
- DKIM is not enabled.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acm_arn | ACM certificate arn (output from pre-control TF) of the environment sub domain | `string` | n/a | yes |
| allowed\_account\_id | The Account Id which hosts the environment | `string` | n/a | yes |
| domain_name | Environment Sub Domain (output from pre-control TF), used for Cloudfront custom domain, may be used for SES domain Identity and Cognito custom domain | `string` | n/a | yes |
| echostream\_version | `Major.Minor` Version to fetch artifacts from right location | `string` | n/a | yes |
| manual_deployment_trigger | Toggle for deployment of all echo tenant and system types, appsync, cloudfront etc. Changing the previous existing value acts as a trigger | `string` | `foobar` | no |
| region | AWS Region for the environment | `string` | n/a | yes |
| resource_prefix | Environment Prefix for naming resources, a Unique name that could differentiate whole environment. `lower case` only, `No periods`, `No Special Char` except `-`. Length less than 15 char | `string` | n/a | yes |
| ses_email_address | Preferred Email Address that SES uses for communication with tenants | `string` | n/a | yes |
| tenant_regions | List of regions where tenants exist | `list(string)` | `[]` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

### Publish Module (Deployment)
- To publish the module, merge/checkout changes from `main` to branch named like `vX.X.X`
- Merging changes into a already existing versioned branch will publish new code on same version.

### Usage
```
module "control" {
  acm_arn                   = module.pre_control.subdomain_acm_arn
  allowed_account_id        = var.allowed_account_id
  domain_name               = module.pre_control.subdomain
  domain_zone_id            = module.pre_control.subdomain_zone_id
  echostream_version        = var.echostream_version
  manual_deployment_trigger = var.manual_deployment_trigger
  region                    = var.region
  resource_prefix           = "${var.resource_prefix}-${var.environment}"
  ses_email_address         = var.ses_email_address
  tenant_regions            = var.tenant_regions

  tags = {
    terraform-workspace = "my-first-dev-app"
  }

  source  = "app.terraform.io/EchoStream/control/aws"
  version = "0.0.2"
}
```

### Notes for Internal team
- Apps userpool MFA is OFF, Password policy length set to 16 instead of maximum
- UI Userpool devices: Remember your users devices is set to `always`
- Resolvers are deployed by shell