variable "vault_roles" {
  default = {
    ci : "oidc-ci-test"
    cd : "oidc-cd-test"
  }
}
