variable "vault_address" {
  type        = string
  description = "The origin URL of the Vault server. This is a URL with a scheme, a hostname, and a port but with no path."
}

variable "bindings_json_pattern" {
  type        = string
  description = "A pattern designating a collection of JSON files to parse for OIDC binding definitions. For pattern format, see [`fileset`](https://www.terraform.io/language/functions/fileset) ."
  default     = "bindings/*.json"
}
