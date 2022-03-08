// Vault token should be provided in VAULT_TOKEN env var
provider "vault" {
  address            = var.vault-address
  add_address_to_env = true
  // Used this example with a self-signed cert Vault, hence skip_tls_verify
  skip_tls_verify = true
}

locals {
  // These two local variables allow us to read a dynamic number of JSON files from the bindings/ directory
  // and load in all JSON resources in the "oidc-bindings" module variable format.
  oidc-binding-files = fileset(path.module, var.bindings-json-pattern)
  oidc-bindings      = flatten([for filepath in local.oidc-binding-files : jsondecode(file("${path.module}/${filepath}"))])
}

module "github-oidc" {
  source = "../../"

  oidc-bindings = local.oidc-bindings
}

data "vault_auth_backend" "generated-backend" {
  path = module.github-oidc.auth-backend-path
}
