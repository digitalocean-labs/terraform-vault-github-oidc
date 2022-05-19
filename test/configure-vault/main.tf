resource "vault_audit" "audit-file" {
  type = "file"

  options = {
    file_path = "/root/vault-audit.log"
  }
}

resource "vault_generic_secret" "example" {
  data_json = <<EOT
{
  "fi": "fofum"
}
EOT
  path      = "secret/foo/bar"
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

output "seed_secret" {
  value = vault_generic_secret.example.data
  sensitive = true
}
