variable "do_token" {
  type        = string
  sensitive   = true
  description = "DigitalOcean API token"
}

variable "droplet_image" {
  type        = string
  description = "The Droplet identifier of the OS distribution on DigitalOcean"
  default     = "ubuntu-22-04-x64"
}

variable "droplet_region" {
  type        = string
  description = "The Droplet region identifier in which the droplet will be created"
  default     = "nyc3"
}

variable "droplet_size" {
  type        = string
  description = "The size of the Droplet"
  default     = "s-1vcpu-1gb-amd"
}
