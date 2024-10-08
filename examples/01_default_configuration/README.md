# Example using the default configuration

Deploys the FSx status monitor with no additional configuration:

- No CloudWatch alarms are set up.
- The monitor is scheduled to run every 5 minutes.

The list of FSx file system identifiers in `main.tf` is empty.
It needs to be populated before deploying this example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.59 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fsx_monitor"></a> [fsx\_monitor](#module\_fsx\_monitor) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_alert_arns"></a> [cloudwatch\_alert\_arns](#output\_cloudwatch\_alert\_arns) | A map of consisting of FSx filesystem identifiers and their CloudWatch metric alarm ARNs. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role. |
<!-- END_TF_DOCS -->
