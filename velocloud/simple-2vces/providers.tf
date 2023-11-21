# --- provider/file ---
provider "aws" {
  region = "us-east-1"
  alias      = "us-east-1"
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
    aws = {
      source = "hashicorp/aws"
    }
  }
}