resource "digitalocean_droplet" "vault" {
  image  = var.droplet-image
  name   = "vault"
  region = var.droplet-region
  size   = var.droplet-size

  ssh_keys = [digitalocean_ssh_key.vault-prepare.fingerprint]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = tls_private_key.vault-prepare.private_key_openssh
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    script = "${path.module}/setup.sh"
  }
}

resource "digitalocean_ssh_key" "vault-prepare" {
  name       = "vault oidc test CI"
  public_key = trimspace(tls_private_key.vault-prepare.public_key_openssh)
}

data "digitalocean_project" "vault-oidc" {
  name = "GitHub OIDC Vault - CI"
}

resource "digitalocean_project_resources" "vault-oidc" {
  project = data.digitalocean_project.vault-oidc.id
  resources = [
    digitalocean_droplet.vault.urn
  ]
}

# DO NOT use this resource in "real" projects.
# See the security notice on https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
# We use this here for the short-lived CI suite
resource "tls_private_key" "vault-prepare" {
  algorithm   = "ED25519"
  ecdsa_curve = "P256"
}

output "vault_ip" {
  value = digitalocean_droplet.vault.ipv4_address
}
