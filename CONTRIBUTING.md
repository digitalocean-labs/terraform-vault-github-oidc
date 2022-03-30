# Contributing

# Setup

1. Install [Terraform-Docs](https://github.com/terraform-docs/terraform-docs)
2. Install [tfsec](https://aquasecurity.github.io/tfsec)
4. Install [pre-commit](https://pre-commit.com/#install) and run:

```bash
pre-commit install --install-hooks
```

All code must pass the pre-commit checks to be merged.

# Development

Leverage the Makefile for easy navigation around the module and its examples.

`make init` will initialize the module and all example directories.

`make validate` will individually run `terraform validate` against all modules and examples in this repo.

`make plan` will generate a plan of the `simple-repo` example.
Have your IP or hostname of a Vault server ready.
Note that you will need to provide your own `VAULT_TOKEN` env var.

`make apply` will run an apply of the `simple-repo` example.
Have your IP or hostname of a Vault server ready.
Note that you will need to provide your own `VAULT_TOKEN` env var.

## Running GitHub Actions workflow locally

Install [act](https://github.com/nektos/act):

```bash
brew install act
```

To test the Terraform, run:

```bash
act -j validate -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
```

If you have a lot of hard drive space, and time, you can test the pre-commit workflow step with:

```bash
act -j pre-commit -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:full-latest
```

This will pull a ~40GB Docker image, so be warned.

However, running `brew install pre-commit && pre-commit run -a` will be much faster and accomplish the same task.
