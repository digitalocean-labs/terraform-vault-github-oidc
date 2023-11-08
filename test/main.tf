module "github_oidc" {
  source = "../"

  github_identity_provider = "https://token.actions.githubusercontent.com/digitalocean"

  oidc_bindings = [
    {
      audience : "https://github.com/digitalocean-labs",
      vault_role_name : var.vault_roles.ci,
      bound_subject : "repo:digitalocean-labs/terraform-vault-github-oidc:pull_request",
      vault_policies : [
        vault_policy.example.name,
      ],
    },
    {
      audience : "https://github.com/digitalocean-labs",
      vault_role_name : var.vault_roles.cd,
      bound_subject : "repo:digitalocean-labs/terraform-vault-github-oidc:ref:refs/heads/main",
      vault_policies : [
        vault_policy.main.name,
      ],
    },
  ]
}

resource "vault_policy" "example" {
  name   = "oidc-example"
  policy = data.vault_policy_document.example.hcl
}

resource "vault_policy" "main" {
  name   = "main-branch-only"
  policy = data.vault_policy_document.main.hcl
}

data "vault_policy_document" "example" {
  rule {
    path         = "secret/data/foo/bar"
    capabilities = ["list", "read"]
  }
}

data "vault_policy_document" "main" {
  rule {
    path         = "secret/data/main/secret"
    capabilities = ["list", "read"]
  }
}

output "vault_roles" {
  value = var.vault_roles
}

output "backend_path" {
  value = module.github_oidc.auth_backend_path
}

output "oidc_bindings_names" {
  value = module.github_oidc.oidc_bindings_names
}
