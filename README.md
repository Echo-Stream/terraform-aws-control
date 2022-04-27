## Control Terraform
Terraform Module Control Resources. 

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|--------|
| allowed\_account\_id | The Account Id which hosts the environment | `string` | n/a | yes |
| authorized\_domains | List of authorized_domains that can signup to the app | `list(string)` | n/a | yes |
| create\_dynamo\_db\_replication\_service\_role| Enable boolean to create a dynamo db replication service role | `bool` | `true` | no |
| domain_name | Your root domain, Used to create environment sub domain certificates used in Control TF | `string` | n/a | yes |
| echostream\_version | `Major.Minor` Version to fetch artifacts from right location | `string` | n/a | yes |
| environment | Environment. Could be environment, stg, prod | `string` | n/a | yes |
| region | AWS Region for the environment | `string` | n/a | yes |
| resource_prefix | Environment Prefix for naming resources, a Unique name that could differentiate whole environment. `lower case` only, `No periods`, `No Special Char` except `-`. Length less than 15 char | `string` | n/a | yes |
| route53\_account\_id | The AWS Account ID, where EchoStream Route53 resides | `string` | n\a | yes |
| route53\_manager\_role\_name | The Name of the role that needs to be assumed to managed DNS records in Corp/EchoStream Route53 | `string` | n/a | yes |
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
- The SES email identity of the ses email address that is being passed in should have been already ready to be used.
- DKIM is not enabled.