// Vault token should be provided in VAULT_TOKEN env var
provider "vault" {
  address = var.vault_address
}

module "github_oidc" {
  source  = "digitalocean/github-oidc/vault"
  version = "~> 2.1.0"

  oidc_bindings = [
    {
      audience : "https://github.com/artis3n",
      vault_role_name : "oidc-test",
      bound_subject : "repo:artis3n/github-oidc-vault-example:environment:nonprod",
      vault_policies : [
        vault_policy.example.name,
      ],
    },
    {
      audience : "https://github.com/artis3n",
      vault_role_name : "oidc-prod-test",
      bound_subject : "repo:artis3n/github-oidc-vault-example:ref:refs/heads/main",
      vault_policies : [
        vault_policy.example.name,
      ],
    },
  ]
}

resource "vault_policy" "example" {
  name   = "oidc-example"
  policy = data.vault_policy_document.example.hcl
}

data "vault_policy_document" "example" {
  rule {
    path         = "secret/data/foo/bar"
    capabilities = ["list", "read"]
  }
}

data "vault_auth_backend" "generated_backend" {
  path = module.github_oidc.auth_backend_path
}
