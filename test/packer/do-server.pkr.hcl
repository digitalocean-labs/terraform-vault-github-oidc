packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.8"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

source "digitalocean" "vault-image" {
  # Authenticate via DIGITALOCEAN_TOKEN env var
  image  = "ubuntu-22-04-x64"
  region = "nyc3"
  size   = "s-1vcpu-1gb-amd"

  ssh_username = "root"
  droplet_name = "packer-vault-base-builder"

  snapshot_name = "packer-vault-base-{{timestamp}}"
}

build {
  sources = ["source.digitalocean.vault-image"]

  # Update base OS
  provisioner "shell" {
    # Sometimes this starts before DO cloud-init finishes putting everything where it is supposed to be, so pause a minute
    pause_before = "1m"
    inline = [
      "DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Lock::Timeout=60 clean",
      "DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Lock::Timeout=60 -y update",
      "DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Lock::Timeout=60 -y full-upgrade",
      "reboot"
    ]
    expect_disconnect = true
  }

  # Install and configure mkcert and Vault
  provisioner "shell" {
    pause_before = "1m"
    script       = "./setup.sh"
  }
}
