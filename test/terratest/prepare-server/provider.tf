terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.21.0"
    }
  }
}

provider "digitalocean" {
  token = var.DO_token
}
