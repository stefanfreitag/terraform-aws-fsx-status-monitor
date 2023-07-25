# Example using a custom schedule

Deploys the FSx status monitor with a non-default configuration:

- No SNS topic subscriber is set up.
- The monitor is scheduled to run every 15 minutes instead of the default interval.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |

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

No outputs.
<!-- END_TF_DOCS -->
