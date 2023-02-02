terraform {
  required_version = ">= 1.3.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.4.1"
    }
  }
}

provider "vault" {
  # Will access a local dev Vault in the GitHub Actions workflow
  # See the `services:` section in .github/workflows/oidc_test.yml
  address = "http://127.0.0.1:8200"

  # We set a VAULT_TOKEN env var
}
