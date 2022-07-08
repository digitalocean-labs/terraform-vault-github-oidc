# JSON Files Example

This example demonstrates a realistic method of allowing development teams in an enterprise setting to self-manage their
own repo bindings to Vault through modifying JSON files while allowing for security control (via CODEOWNERS or other PR approval)
of changes, if necessary.

Note that this method precludes effective use of [`vault_policy`](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy)
resources to generate policy names.
This method is most effective if policies are generated in a separate process and passed in as part of the rest of the JSON configuration.

# Usage

Dev teams create their own JSON files representing repos they own and wish to bind to a Vault role.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 3.4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_oidc"></a> [github\_oidc](#module\_github\_oidc) | digitalocean/github-oidc/vault | ~> 1.0.2 |

## Resources

| Name | Type |
|------|------|
| [vault_auth_backend.generated_backend](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/auth_backend) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vault_address"></a> [vault\_address](#input\_vault\_address) | The origin URL of the Vault server. This is a URL with a scheme, a hostname, and a port but with no path. | `string` | n/a | yes |
| <a name="input_bindings_json_pattern"></a> [bindings\_json\_pattern](#input\_bindings\_json\_pattern) | A pattern designating a collection of JSON files to parse for OIDC binding definitions. For pattern format, see [`fileset`](https://www.terraform.io/language/functions/fileset) . | `string` | `"bindings/*.json"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_backend_accessor"></a> [auth\_backend\_accessor](#output\_auth\_backend\_accessor) | The generated accessor ID for the auth backend. Outputting as demonstration of using a data source with the module. |
| <a name="output_backend"></a> [backend](#output\_backend) | Exposing the auth backend path as an example. |
| <a name="output_roles"></a> [roles](#output\_roles) | The list of Vault role names created by the module. This is a reflection of the `vault_role_name` value of each input item in `oidc-bindings`. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
