provider "vault" {
  address = "https://${data.terraform_remote_state.server-prep.outputs.vault_ip}:8200"
  # Used this example with a self-signed cert Vault, hence skip_tls_verify
  # Don't do this outside of debugging and testing
  skip_tls_verify = true
  # See setup.sh, also don't...hard-code your root token. Normally.
  token = "dovaultrootpass"
}

data "terraform_remote_state" "server-prep" {
  backend = "local"

  config = {
    path = "${path.module}/../prepare-server/terraform.tfstate"
  }
}
