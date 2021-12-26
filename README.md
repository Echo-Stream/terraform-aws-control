## Control Terraform
Terraform Module for Echo Stream Control Resources. It creates all control structure of echostream environment on aws.
This module is supposed to be used along with pre-control module in the EchoStream environment.


### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|--------|
| app_acm_arn | ACM certificate arn (output from pre-control TF) of the environment sub domain - application | `string` | n/a | yes |
| api_acm_arn | ACM certificate arn (output from pre-control TF) of the environment sub domain - api | `string` | n/a | yes |
| allowed\_account\_id | The Account Id which hosts the environment | `string` | n/a | yes |
| domain_name | Environment Sub Domain (output from pre-control TF), used for Cloudfront custom domain, may be used for SES domain Identity and Cognito custom domain | `string` | n/a | yes |
| echostream\_version | `Major.Minor` Version to fetch artifacts from right location | `string` | n/a | yes |
| region | AWS Region for the environment | `string` | n/a | yes |
| resource_prefix | Environment Prefix for naming resources, a Unique name that could differentiate whole environment. `lower case` only, `No periods`, `No Special Char` except `-`. Length less than 15 char | `string` | n/a | yes |
| ses_email_address | Preferred Email Address that SES uses for communication with tenants | `string` | n/a | yes |
| tenant_regions | List of regions where tenants exist | `list(string)` | `[]` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |


### Outputs

| Name | Description |
|------|-------------|
| appsync_id | Main API ID of the EchoStream |
| appsync_url| API URL of the EchoStream |
| apps_user_pool_id | The ID of the apps cognito user pool |
| apps_user_pool_arn| The ARN of the apps cognito user pool |
| apps_user_pool_endpoint | Endpoint of the apps cognito user pool |
| apps_user_pool_client_id | The ID of the apps cognito user pool client |
| ui_user_pool_id | The ID of the UI cognito user pool |
| ui_user_pool_arn | The ARN of the UI cognito user pool |
| ui_user_pool_endpoint | Endpoint of the UI cognito user pool |
| ui_user_pool_client_id | The ID of the UI cognito user pool client |
| identity_pool_id | EchoStream Identity pool ID |
| identity_pool_arn | The ARN of the EchoStream identity pool |
| cloudfront_oai_id | The identifier for the EchoStream CloudFront distribution |
| cloudfront_oai_iam_arn | EchoStream Cloudfront orgin access identity. Pre-generated ARN for use in S3 bucket policies |
| cloudfront_domain_name | EchoStream CloudFront distribution Domain name |


### CI/CD for Publish Module (.github/workflows/publish.yml)
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
### Important Note
- Domain name and ACM certificate covering the domain Inputs are needed. These resources are created by Pre control TF.
- This module is supported in all Regions except `US-WEST-1` region
- Verifying an email address provided to SES service is manual. User needs to verify a link that is sent by AWS SES to the provided email.
- DKIM is not enabled.
- Adding custom domain and its association with API is not supported in TF yet, it is done manually.

### Notes for Internal team
- Apps userpool MFA is OFF, Password policy length set to 16 instead of maximum
- UI Userpool devices: Remember your users devices is set to `always`