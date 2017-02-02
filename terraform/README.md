# devops-scripts/terraform

## Overview

The `terraform/` directory in `devops-scripts` defines our infrastructure
as code via [Hashicorp's Terraform Tool](https://terraform.io). To begin let's look
at the overall file structure:

- `devops-scripts/terraform/*` all files in `terraform` are sourced and used when running commands

## File naming conventions

- `*.tf` all tf files
- `*-vars.tf` Files appended with `-vars.tf` hold variables for the preceding type

## Key Files

- `common-vars.tf` - defines common variables throughout our infrastructure

## How to develop

1. Set `TF_VAR_aws_access_key` and `TF_VAR_aws_secret_key` environment variable to your AWS access credentials
3. Make changes to the `*.tf` files that describe your infrastructure change.
4. Run `terraform plan` from the directory that your change is in
5. Once satisfied with the resulting diff, run `terraform apply` to apply changes.
