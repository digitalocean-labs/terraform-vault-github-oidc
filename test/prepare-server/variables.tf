variable "DO_token" {
  type        = string
  sensitive   = true
  description = "DigitalOcean API token"
}

variable "droplet-image" {
  type        = string
  description = "The Droplet identifier of the OS distribution on DigitalOcean"
  default     = "ubuntu-22-04-x64"
}

variable "droplet-region" {
  type        = string
  description = "The Droplet region identifier in which the droplet will be created"
  default     = "nyc3"
}

variable "droplet-size" {
  type        = string
  description = "The size of the Droplet"
  default     = "s-1vcpu-1gb"
}
