## Control Terraform
Terraform Module for Echo Stream Control Resources

### Important Note
- Domain name and ACM certificate covering the domain Inputs are needed. This resources are created by Pre control TF.
- This module is supported in all US Regions except `US-WEST-1` region
- Verifying an email address provided to SES service is manual. User needs to verify a link that is sent by AWS SES to the provided email.
- DKIM is not enabled.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_account\_id | The Account Id which hosts the environment | `string` | n/a | yes |
| echostream\_version | `Major.Minor` Version to fetch artifacts from right location | `string` | n/a | yes |
| resource_prefix | Environment Prefix for naming resources, a Unique name that could differentiate whole environment. `lower case` only, `No periods`, `No Special Char` except `-`. Length less than 15 char | `string` | n/a | yes |
| domain_name |Environment Sub Domain (output from pre-control TF), used for Cloudfront custom domain, may be used for SES domain Identity and Cognito custom domain | `string` | n/a | yes |
| ses_email_address | Preferred Email Address that SES uses for communication with tenants | `string` | n/a | yes |
| region | AWS Region for the environment | `string` | n/a | yes |
| acm_arn | ACM certificate arn (output from pre-control TF) of the environment sub domain | `string` | n/a | yes |
| tenant_regions | List of regions where tenants exist | `list(string)` | `[]` | no |
| manual_deployment_trigger | Toggle for deployment of all echo tenant and system types, appsync, cloudfront etc. Changing the previous existing value acts as a trigger | `string` | `foobar` | no |

### Notes for Internal team
- Apps userpool MFA is OFF, Password policy length set to 16 instead of maximum
- UI Userpool devices: Remember your users devices is set to `always`
- Resolvers are deployed by shell