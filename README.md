# Terraform Module: Hashicorp Vault GitHub OIDC

Terraform module to configure Vault for GitHub OIDC authentication from Action runners.

# Usage

TBA

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

No modules.

## Resources

| Name | Type |
|------|------|
| [vault_jwt_auth_backend.github-oidc](https://registry.terraform.io/providers/hashicorp/vault/3.3.1/docs/resources/jwt_auth_backend) | resource |
| [vault_jwt_auth_backend_role.github-oidc-role](https://registry.terraform.io/providers/hashicorp/vault/3.3.1/docs/resources/jwt_auth_backend_role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oidc-bindings"></a> [oidc-bindings](#input\_oidc-bindings) | A list of OIDC JWT bindings between GitHub repos and Vault roles. For each entry, you must include:<br><br>  `audience`: This must match the `jwtGithubAudience` parameter in [hashicorp/vault-action](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault#requesting-the-access-token) . This is the bound audience (`aud`) field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) .<br><br>  `vault_role_name`: The name of the Vault role to generate under the OIDC auth backend.<br><br>  `bound_subject`: This is what is set in the `sub` field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . The bound subject can be constructed from various filters, such as a branch, tag, or specific [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) . See [GitHub's documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims) for examples.<br><br>  `vault_policies`: A list of Vault policies you wish to grant to the generated token.<br><br>  `user_claim`: **Optional**. This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client. This will be used as the name for the Identity entity alias created due to a successful login. This must be a field present in the [GitHub JWT token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . Defaults to the `default-user-claim` variable if not provided.<br><br>  `ttl`: **Optional**. The default incremental time-to-live for the generated token, in seconds. Defaults to the `default-ttl` value but can be individually specified per binding with this value. | <pre>list(object({<br>    audience        = string,<br>    vault_role_name = string,<br>    bound_subject   = string,<br>    vault_policies  = set(string),<br>    user_claim      = optional(string),<br>    ttl             = optional(number),<br>  }))</pre> | n/a | yes |
| <a name="input_default-ttl"></a> [default-ttl](#input\_default-ttl) | The default incremental time-to-live for generated tokens, in seconds. | `number` | `600` | no |
| <a name="input_default-user-claim"></a> [default-user-claim](#input\_default-user-claim) | This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client. This will be used as the name for the Identity entity alias created due to a successful login. This must be a field present in the [GitHub OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . | `string` | `"job_workflow_ref"` | no |
| <a name="input_oidc-auth-backend-path"></a> [oidc-auth-backend-path](#input\_oidc-auth-backend-path) | The path to mount the OIDC auth backend. | `string` | `"github-actions"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth-backend-path"></a> [auth-backend-path](#output\_auth-backend-path) | The path of the generated auth method. Use with a `vault_auth_backend` data source to retrieve any needed attributes from this resource. |
| <a name="output_oidc-bindings-names"></a> [oidc-bindings-names](#output\_oidc-bindings-names) | The Vault role names generated for each OIDC binding provided. This is a reflection of the `vault_role_name` value of each item in `oidc-bindings`. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Authors

TBA

# License

MIT licensed. See [LICENSE](LICENSE) for full details.
