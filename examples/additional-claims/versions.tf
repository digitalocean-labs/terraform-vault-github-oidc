terraform {
  required_version = ">= 1.1.7"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = " ~> 3.3.1"
    }
  }
}
