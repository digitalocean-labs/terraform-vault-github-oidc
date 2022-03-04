// Vault token should be provided in VAULT_TOKEN env var
provider "vault" {
  address            = var.vault-address
  add_address_to_env = true
  // Used this example with a self-signed cert Vault, hence skip_tls_verify
  skip_tls_verify = true
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

data "vault_auth_backend" "generated-backend" {
  path = module.github-oidc.auth-backend-path
}
