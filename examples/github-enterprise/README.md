# GitHub Enterprise Server Example

Example configuration in this directory binds multiple Vault roles to one GitHub repository with GitHub OIDC.
When using GitHub Enterprise Server, configure this module as normal and update the `github_identity_provider` variable [as applicable](https://github.com/digitalocean/terraform-vault-github-oidc#github_identity_provider) for your GitHub server.

# Usage

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 3.4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.8.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_oidc"></a> [github\_oidc](#module\_github\_oidc) | digitalocean/github-oidc/vault | ~> 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [vault_policy.example](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_auth_backend.generated_backend](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/auth_backend) | data source |
| [vault_policy_document.example](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vault_address"></a> [vault\_address](#input\_vault\_address) | The origin URL of the Vault server. This is a URL with a scheme, a hostname, and a port but with no path. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_backend_accessor"></a> [auth\_backend\_accessor](#output\_auth\_backend\_accessor) | The generated accessor ID for the auth backend. Outputting as demonstration of using a data source with the module. |
| <a name="output_backend"></a> [backend](#output\_backend) | Exposing the auth backend path as an example. |
| <a name="output_roles"></a> [roles](#output\_roles) | The list of Vault role names created by the module. This is a reflection of the `vault_role_name` value of each input item in `oidc-bindings`. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
