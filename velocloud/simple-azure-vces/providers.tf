# --- provider/file ---
provider "azurerm" {
  features {}
}

provider "velocloud" {
  alias                 = "sdwan"
  vco                   = var.vco_address
  username              = var.vco_username
  password              = var.vco_password
  skip_ssl_verification = false
}

terraform {
  required_providers {
    velocloud = {
      source = "adeleporte/velocloud"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}