## Control Terraform
Terraform Module for Echo Stream Control Resources. It creates the control structure of echostream environment on aws.
This module is supposed to be used along with pre-control module in the EchoStream environment.


### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|--------|
| allowed\_account\_id | The Account Id which hosts the environment | `string` | n/a | yes |
| app_acm_arn | ACM certificate arn (output from pre-control TF) of the environment sub domain - application | `string` | n/a | yes |
| app_domain_name | Application Domain name of the environment which may be used for Cognito custom auth, SES domain Identity and Cloudfront custom domain | `string` | n/a | yes |
| authorized\_domains | List of authorized_domains that can signup to the app | `list(string)` | n/a | yes |
| docs_api_acm_arn | ACM certificate arn (output from pre-control TF) of the environment sub domain - docs-api | `string` | n/a | yes |
| docs_api_domain_name | Domain name of the environment used for API Documentation | `string` | n/a | yes |
| echostream\_version | `Major.Minor` Version to fetch artifacts from right location | `string` | n/a | yes |
| region | AWS Region for the environment | `string` | n/a | yes |
| regional\_apis | A map with regional api acm arns and domain names | `any` | `{}` | no |
| resource_prefix | Environment Prefix for naming resources, a Unique name that could differentiate whole environment. `lower case` only, `No periods`, `No Special Char` except `-`. Length less than 15 char | `string` | n/a | yes |
| ses_email_address | Preferred Email Address that SES uses for communication with tenants | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| tenant_regions | List of regions where tenants exist | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| api_user_pool_arn| The ARN of the API cognito user pool |
| api_user_pool_client_id | The ID of the API cognito user pool client |
| api_user_pool_endpoint | Endpoint of the API cognito user pool |
| api_user_pool_id | The ID of the API cognito user pool |
| appsync_custom_url | Custom API URL of the EchoStream |
| appsync_id | Main API ID of the EchoStream |
| appsync_url| API URL of the EchoStream |
| cloudfront_domain_name_api_docs | EchoStream API Docs CloudFront distribution Domain name to be added in to Route53 |
| cloudfront_domain_name_webapp | EchoStream Webapp CloudFront distribution Domain name to be added in to Route53 |
| cloudfront_hosted_zone_id | Standard CloudFront distribution Hosted Zone ID to be used in route53 for webapp and docs cloudfront records |
| cloudfront_oai_iam_arn_api_docs | EchoStream API Docs Cloudfront origin access identity. Pre-generated ARN for use in S3 bucket policies |
| cloudfront_oai_iam_arn_webapp | EchoStream Webapp Cloudfront origin access identity. Pre-generated ARN for use in S3 bucket policies |
| cloudfront_oai_id_api_docs | The identifier for the EchoStream API Docs CloudFront distribution |
| cloudfront_oai_id_webapp | The identifier for the EchoStream Webapp CloudFront distribution |
| ui_user_pool_arn | The ARN of the UI cognito user pool |
| ui_user_pool_client_id | The ID of the UI cognito user pool client |
| ui_user_pool_endpoint | Endpoint of the UI cognito user pool |
| ui_user_pool_id | The ID of the UI cognito user pool |


### CI/CD for Publish Module (.github/workflows/publish.yml)
- To publish the module, merge/checkout changes from `main` to branch named like `vX.X.X`
- Merging changes into a already existing versioned branch will publish new code on same version.

### Usage
```
module "control" {
  allowed_account_id   = var.allowed_account_id
  app_acm_arn          = module.pre_control.app_acm_arn
  app_domain_name      = module.pre_control.app_domain_name
  authorized_domains   = var.authorized_domains
  docs_api_acm_arn     = module.pre_control.docs_api_acm_arn
  docs_api_domain_name = module.pre_control.docs_api_domain_name
  echostream_version   = var.echostream_version
  region               = var.region
  regional_apis        = module.pre_control.regional_apis
  resource_prefix      = "${var.resource_prefix}-${var.environment}"
  ses_email_address    = var.ses_email_address
  tags                 = local.tags
  tenant_regions       = var.tenant_regions

  source = "app.terraform.io/EchoStream/control/aws"
}

```
### Important Note
- Domain name and ACM certificate covering the domain Inputs are needed. These resources are created by Pre control TF.
- Verifying an email address provided to SES service is a manual task. User needs to verify a link that is sent by AWS SES to the provided email.
- DKIM is not enabled.

### Notes for Internal team
- UI Userpool devices: Remember your users devices is set to `always`