# JSON Files Example

This example demonstrates a realistic method of allowing development teams in an enterprise setting to self-manage their
own repo bindings to Vault through modifying JSON files while allowing for security control (via CODEOWNERS or other PR approval)
of changes, if necessary.

# Usage

Dev teams create their own JSON files representing repos they own and wish to bind to a Vault role.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.1.7 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 3.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github-oidc"></a> [github-oidc](#module\_github-oidc) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [vault_auth_backend.generated-backend](https://registry.terraform.io/providers/hashicorp/vault/3.3.1/docs/data-sources/auth_backend) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vault-address"></a> [vault-address](#input\_vault-address) | The origin URL of the Vault server. This is a URL with a scheme, a hostname, and a port but with no path. | `string` | n/a | yes |
| <a name="input_bindings-json-pattern"></a> [bindings-json-pattern](#input\_bindings-json-pattern) | A pattern designating a collection of JSON files to parse for OIDC binding definitions. For pattern format, see [`fileset`](https://www.terraform.io/language/functions/fileset). | `string` | `"bindings/*.json"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth-backend-accessor"></a> [auth-backend-accessor](#output\_auth-backend-accessor) | The generated accessor ID for the auth backend. Outputting as demonstration of using a data source with the module. |
| <a name="output_backend"></a> [backend](#output\_backend) | Exposing the auth backend path as an example. |
| <a name="output_roles"></a> [roles](#output\_roles) | The list of Vault role names created by the module. This is a reflection of the `vault_role_name` value of each input item in `oidc-bindings`. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
