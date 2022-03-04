variable "oidc-auth-backend-path" {
  type        = string
  description = "The path to mount the OIDC auth backend."
  default     = "github-actions"
}

variable "default-ttl" {
  type        = number
  description = "The default incremental time-to-live for generated tokens, in seconds."
  default     = 600 # 10 minutes
}

variable "default-user-claim" {
  type        = string
  description = "This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client. This will be used as the name for the Identity entity alias created due to a successful login. This must be a field present in the [GitHub OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) ."
  default     = "job_workflow_ref"
}

variable "oidc-bindings" {
  type = list(object({
    audience        = string,
    vault_role_name = string,
    bound_subject   = string,
    vault_policies  = set(string),
    user_claim      = optional(string),
    ttl             = optional(number),
  }))

  description = <<-EOT
    A list of OIDC JWT bindings between GitHub repos and Vault roles. For each entry, you must include:

      `audience`: This must match the `jwtGithubAudience` parameter in [hashicorp/vault-action](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault#requesting-the-access-token) . This is the bound audience (`aud`) field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) .

      `vault_role_name`: The name of the Vault role to generate under the OIDC auth backend.

      `bound_subject`: This is what is set in the `sub` field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . The bound subject can be constructed from various filters, such as a branch, tag, or specific [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) . See [GitHub's documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims) for examples.

      `vault_policies`: A list of Vault policies you wish to grant to the generated token.

      `user_claim`: **Optional**. This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client. This will be used as the name for the Identity entity alias created due to a successful login. This must be a field present in the [GitHub JWT token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . Defaults to the `default-user-claim` variable if not provided.

      `ttl`: **Optional**. The default incremental time-to-live for the generated token, in seconds. Defaults to the `default-ttl` value but can be individually specified per binding with this value.

    EOT
}
