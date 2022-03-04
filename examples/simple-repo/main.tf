// Vault token should be provided in VAULT_TOKEN env var
provider "vault" {
  address            = var.vault-address
  skip_tls_verify    = true //
  add_address_to_env = true
}

module "github-oidc" {
  source = "../../"

  oidc-bindings = [
    {
      audience : "artis3n-test",
      vault_role_name : "oidc-test",
      bound_subject : "repo:artis3n/github-oidc-vault-example:environment:nonprod",
      vault_policies : [
        "oidc-policy"
      ],
    },
    {
      audience : "artis3n-prod-test",
      vault_role_name : "oidc-prod-test",
      bound_subject : "repo:artis3n/github-oidc-vault-example:ref:refs/heads/main",
      vault_policies : [
        "oidc-policy"
      ],
    }
  ]
}
