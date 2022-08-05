# tfsec:ignore:digitalocean-compute-use-ssh-keys
resource "digitalocean_droplet" "vault" {
  image  = var.droplet_image
  name   = "github-oidc-vault-server"
  region = var.droplet_region
  size   = var.droplet_size

  ssh_keys = [digitalocean_ssh_key.vault_prepare.fingerprint]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = tls_private_key.vault_prepare.private_key_openssh
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    script = "${path.module}/setup.sh"
  }
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
