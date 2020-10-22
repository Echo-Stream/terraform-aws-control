## Control Terraform
Terraform Module for HL7 Ninja Control Resources

### Important Note 
- Apps userpool MFA is OFF, Password policy length set to 16 instead of maximum
- Resolvers are deployed by shell
- Verifying an email address provided to SES service is manual. User needs to verify a link that is sent by AWS SES to the provided email.
- DKIM is not enabled.
- Domain name and ACM certificate covering that domain Inputs are needed. This resources can be created by Pre control TF or hand made.
- Cognito is not supported in `US-WEST-1` region

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_account\_id | The Account Id which hosts the environment | `string` | n/a | yes |
| hl7\_ninja\_version | `Major.Minor` Version to fetch artifacts from right location | `string` | n/a | yes |
| environment_prefix | Environment Prefix for naming resources, a Unique name that could differentiate whole environment. lower case only, No periods, No Special Char except -. Length less than 15 char | `string` | n/a | yes |
| domain_name |Environment Sub Domain (output from pre-control TF), used for Cloudfront custom domain, may be used for SES domain Identity and Cognito custom domain | `string` | n/a | yes |
| ses_email_address | Preferred Email Address that SES uses for communication with tenants | `string` | n/a | yes |
| region | AWS Region for the environment | `string` | n/a | yes |
| acm_arn | ACM certificate arn (output from pre-control TF) of the environment sub domain | `string` | n/a | yes |