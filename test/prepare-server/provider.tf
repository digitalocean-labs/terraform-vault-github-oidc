terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.19.0"
    }
  }
}

provider "digitalocean" {
  token = var.DO_token
}
