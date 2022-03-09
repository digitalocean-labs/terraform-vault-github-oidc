output "auth_backend_path" {
  description = "The path of the generated auth method. Use with a `vault_auth_backend` data source to retrieve any needed attributes from this resource."
  value       = vault_jwt_auth_backend.github_oidc.path
}

output "oidc_bindings_names" {
  description = "The Vault role names generated for each OIDC binding provided. This is a reflection of the `vault_role_name` value of each item in `oidc-bindings`."
  value       = values(vault_jwt_auth_backend_role.github_oidc_role)[*].role_name
}
