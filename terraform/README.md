# devops-scripts/terraform

## Overview
The `terraform/` directory in `devops-scripts` defines our sandboxes infrastructure
as code via [Hashicorp's Terraform Tool](https://terraform.io). To begin let's look
at the overall directory structure:

- `Makefile` - Makefile used to build, destroy, and mutate the sandboxes AWS infrastructure.
- `environment/` - Holds variable definitions for each of the environments we maintain.
- `sandbox/` - Contains the Terraform files (`*.tf`) that describe the sandboxes infrastructure.

Take a moment to familiarize yourself with the layout of the files listed above.

## How to develop

1. Set the `TERRAFORM_ENVIRONMENT` environment variable to `zeta` in your shell.
2. Get a copy of the `credentials.tfvars` file from @rsandor.
3. Make changes to the `*.tf` files that describe your infrastructure change.
4. Run `make plan` from the `terraform/` directory
5. Once satisfied with the resulting diff, run `make apply` to apply changes.

**Note:** currently only members of the devops team are allowed to have credentials
that can mutate the entire infrastructure. For the foreseeable future no execeptions
will be made.
