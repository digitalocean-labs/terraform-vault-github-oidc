resource "vault_jwt_auth_backend" "github_oidc" {
  description        = "Binds an OIDC JWT auth backend to GitHub Actions."
  path               = var.oidc_auth_backend_path
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
  bound_issuer       = "https://token.actions.githubusercontent.com"
}

locals {
  additional_claims = { for binding in var.oidc_bindings : binding.vault_role_name => binding.additional_claims }
}

resource "vault_jwt_auth_backend_role" "github_oidc_role" {
  # Converts the list of objects into a map of Vault role name => whole object.
  # This uniquely identifies each resource by its Vault role name.
  # This allows Terraform to properly track state across items in the for loop.
  for_each = { for binding in var.oidc_bindings : binding.vault_role_name => binding }

  role_type = "jwt"
  backend   = vault_jwt_auth_backend.github_oidc.path

  role_name       = each.value.vault_role_name # Equivalent to each.key but explicitly using value for demonstration purposes
  user_claim      = each.value.user_claim != null ? each.value.user_claim : var.default_user_claim
  bound_audiences = [each.value.audience]
  # Use bound_claims.sub instead of bound_subject, even though both evaluate the "sub" claim in the JWT.
  #
  # bound_subject is syntactic sugar around bound_claims.sub and doesn't play well with terraform state in the
  # current version of the provider.
  # Using `bound_subject` alone results in continual terraform drift, as Vault will generate bound_claims.sub
  # in its data but re-running an apply will remove bound_claims.sub.
  # So, either declare both to be the same value or just use bound_claims.sub.
  # We're doing the latter.
  bound_subject = ""
  # Add any additional claims a user has entered.
  # Ensure the bound_subject parameter overwrites any other sub declarations (second map in merge overwrites existing key if present).
  bound_claims      = local.additional_claims[each.key] != null ? merge(local.additional_claims[each.key], { sub = each.value.bound_subject }) : { sub = each.value.bound_subject }
  bound_claims_type = "glob"

  token_policies = each.value.vault_policies
  token_ttl      = each.value.ttl != null ? each.value.ttl : var.default_ttl
}
