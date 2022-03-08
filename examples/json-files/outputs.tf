output "backend" {
  description = "Exposing the auth backend path as an example."
  value       = module.github-oidc.auth-backend-path
}

output "auth-backend-accessor" {
  description = "The generated accessor ID for the auth backend. Outputting as demonstration of using a data source with the module."
  value       = data.vault_auth_backend.generated-backend.accessor
}

output "roles" {
  description = "The list of Vault role names created by the module. This is a reflection of the `vault_role_name` value of each input item in `oidc-bindings`."
  value       = module.github-oidc.oidc-bindings-names
}
