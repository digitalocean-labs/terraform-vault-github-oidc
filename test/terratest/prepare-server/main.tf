# tfsec:ignore:digitalocean-compute-use-ssh-keys
resource "digitalocean_droplet" "vault" {
  image         = data.digitalocean_droplet_snapshot.vault-snapshot.id
  name          = "github-oidc-vault-server"
  region        = var.droplet_region
  size          = var.droplet_size
  droplet_agent = false

  ssh_keys = [digitalocean_ssh_key.vault_prepare.fingerprint]

  user_data = file("${path.module}/userdata.sh")

  # Wait for the user data script to run and start Vault
  # This is relatively brittle, and if it is too short relative
  # to the runtime of cloud-init and the userdata script, Vault
  # will not be available and the tests will fail.
  provisioner "local-exec" {
    command = "sleep 90"
  }
}

# This image is built weekly from test/packer
# See the .github/workflows/build-image.yml workflow
data "digitalocean_droplet_snapshot" "vault-snapshot" {
  name_regex  = "^packer-vault-base-*"
  region      = var.droplet_region
  most_recent = true
}

resource "digitalocean_ssh_key" "vault_prepare" {
  name       = "vault oidc test CI"
  public_key = trimspace(tls_private_key.vault_prepare.public_key_openssh)
}

data "digitalocean_project" "vault_oidc" {
  name = "GitHub OIDC Vault - CI"
}

resource "digitalocean_project_resources" "vault_oidc" {
  project = data.digitalocean_project.vault_oidc.id
  resources = [
    digitalocean_droplet.vault.urn
  ]
}

# DO NOT use this resource in "real" projects.
# See the security notice on https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
# We use this here for the short-lived CI suite
resource "tls_private_key" "vault_prepare" {
  algorithm   = "ED25519"
  ecdsa_curve = "P256"
}

output "vault_ip" {
  value = digitalocean_droplet.vault.ipv4_address
}
