terraform {
  required_providers {
    prismasdwan = {
      source  = "paloaltonetworks/prismasdwan"
      version = "6.5.2-ga.1"
    }
  }
}

variable "client_id"     {}
variable "client_secret" {}
variable "tsg_id"        {}

provider "prismasdwan" {
  client_id     = var.client_id
  client_secret = var.client_secret
  scope         = "tsg_id:${var.tsg_id}"
}

# POV Test: Create a single site
resource "prismasdwan_site" "dc" {
  name = "Datacenter-TF"
  description = "Managed by Prisma SDWAN Terraform IaaC Provider"
  tags = ["tag1", "tag2","tag3"]
  admin_state = "active"
  address = {
    city = "Frankfurt am Main"
    state = "Hesse"
    country = "Germany"
  }
  location = {
    longitude = 8.683012
    latitude = 50.110596
  }
  element_cluster_role = "HUB"
  prefer_lan_default_over_wan_default_route = false
  app_acceleration_enabled = false
  branch_gateway = false
}

output "site_id" {
  value = prismasdwan_site.dc.id
}
