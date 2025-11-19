<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.72.0, < 6.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 3.18.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 4.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda"></a> [lambda](#module\_lambda) | git@github.com:companieshouse/terraform-modules.git//aws/lambda | feature/dvop-3499-updaate-cloudwatch-event-target-inputs-and-event-rule-outputs |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.get_param_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnets.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [vault_generic_secret.service_secrets](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.stack_secrets](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | The AWS account to deploy in to | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region that resources will be created within | `string` | n/a | yes |
| <a name="input_cron_account_validator_cleanup_submissions"></a> [cron\_account\_validator\_cleanup\_submissions](#input\_cron\_account\_validator\_cleanup\_submissions) | The cron string for the account validator cleanup submission cloudwatch event rule. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the specific environment being deployed | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | The entrypoint in the Lambda function. | `string` | `"dist/index.handler"` | no |
| <a name="input_hashicorp_vault_password"></a> [hashicorp\_vault\_password](#input\_hashicorp\_vault\_password) | The password used when retrieving configuration from Hashicorp Vault | `string` | n/a | yes |
| <a name="input_hashicorp_vault_username"></a> [hashicorp\_vault\_username](#input\_hashicorp\_vault\_username) | The username used when retrieving configuration from Hashicorp Vault | `string` | n/a | yes |
| <a name="input_lambda_logs_retention_days"></a> [lambda\_logs\_retention\_days](#input\_lambda\_logs\_retention\_days) | The number of days to retain Lambda logs in CloudWatch | `number` | `7` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | The lambda runtime to run the application | `string` | `"nodejs22.x"` | no |
| <a name="input_memory_megabytes"></a> [memory\_megabytes](#input\_memory\_megabytes) | The amount of memory to allocate to the Lambda function | `string` | `"320"` | no |
| <a name="input_open_lambda_environment_variables"></a> [open\_lambda\_environment\_variables](#input\_open\_lambda\_environment\_variables) | Lambda environment variables that do not require encryption. | `map(string)` | `{}` | no |
| <a name="input_release_artifact_key"></a> [release\_artifact\_key](#input\_release\_artifact\_key) | The release artifact key for the Lambda function | `string` | n/a | yes |
| <a name="input_release_bucket_name"></a> [release\_bucket\_name](#input\_release\_bucket\_name) | The S3 release bucket location containing the function code. | `string` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | The name of service being deployed | `string` | `"configurable-api-caller"` | no |
| <a name="input_timeout_seconds"></a> [timeout\_seconds](#input\_timeout\_seconds) | The amount of time the Lambda function has to run in seconds. | `string` | `"15"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->