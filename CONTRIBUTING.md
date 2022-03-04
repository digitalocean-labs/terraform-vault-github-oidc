# Contributing

# Setup

1. Install [Terraform-Docs](https://github.com/terraform-docs/terraform-docs)
2. Install [tfsec](https://aquasecurity.github.io/tfsec)
4. Install [pre-commit](https://pre-commit.com/#install) and run:

```bash
pre-commit install --install-hooks
```

# Development

Leverage the Makefile for easy navigation around the module and its examples.

`make init` will initialize the module and all example directories.

`make validate` will individually run `terraform validate` against all modules and examples in this repo.

`make plan` will generate a plan of the `simple-repo` example.

`make apply` will run an apply of the `simple-repo` example. Have your IP or hostname of a Vault server ready.
