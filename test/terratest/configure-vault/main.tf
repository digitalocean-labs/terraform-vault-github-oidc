resource "vault_audit" "audit-file" {
  type = "file"

  options = {
    file_path = "/root/vault-audit.log"
  }
}

resource "vault_generic_secret" "ci_example" {
  data_json = <<EOT
{
  "fi": "fofum"
}
EOT
  path      = "secret/foo/bar"
}

resource "vault_generic_secret" "cd_example" {
  data_json = <<EOT
{
  "cdsecret": "only accessible from the main branch"
}
EOT
  path      = "secret/main/secret"
}

resource "vault_policy" "read_policy" {
  name   = "oidc-default-policy"
  policy = data.vault_policy_document.read_foo.hcl
}

data "vault_policy_document" "read_foo" {
  rule {
    path         = "secret/data/foo/bar"
    capabilities = ["list", "read"]
  }
}

output "ci_secret" {
  value     = vault_generic_secret.ci_example.data
  sensitive = true
}

output "cd_secret" {
  value     = vault_generic_secret.cd_example.data
  sensitive = true
}
