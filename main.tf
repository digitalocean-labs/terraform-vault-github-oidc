resource "vault_jwt_auth_backend" "github-oidc" {
  description        = "Bind an OIDC JWT auth backend to GitHub Actions."
  path               = var.oidc-auth-backend-path
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
  bound_issuer       = "https://token.actions.githubusercontent.com"
  default_role       = var.default-oidc-role-name
}

resource "vault_jwt_auth_backend_role" "github-oidc-role" {
  for_each = { for binding in var.oidc-bindings : binding.vault_role_name => binding }

  role_type = "jwt"
  backend   = vault_jwt_auth_backend.github-oidc.path

  role_name       = each.value.vault_role_name
  user_claim      = each.value.user_claim != null ? each.value.user_claim : var.default-user-claim
  bound_audiences = [each.value.audience]
  # Use bound_claims.sub instead of bound_subject - even though both evaluate the "sub" claim in the JWT
  # because we need to support wildcard "glob" entries, which we can configure through bound_claims
  # e.g. sub of "repo:digitalocean/example:ref:refs/*"
  bound_subject = ""
  bound_claims = {
    sub = each.value.bound_subject
  }
  bound_claims_type = "glob"

  token_policies = each.value.vault_policies
  token_ttl      = each.value.ttl != null ? each.value.ttl : var.default-ttl
}
