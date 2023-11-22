module "velo_byol" {
  source = "./modules/velo-byol"
  providers = {
    velocloud = velocloud.sdwan
  }
  count = var.velo_vm_count
  region = azurerm_resource_group.this.location
  zone = var.availability_zones[count.index%length(var.availability_zones)]
  zones = var.availability_zones
  resource_group_name = azurerm_resource_group.this.name
  velo_vm_name = "${var.velo_vm_name}-${count.index+1}"
  vco_edge_name = "vce-${count.index+1}"
  public_subnet_id = azurerm_subnet.public.id
  trust_subnet_id = azurerm_subnet.trust.id
  velo_size = var.velo_size
  velo_version = var.velo_version
  admin_username = var.admin_username
  admin_password = var.admin_password
  vco_url        = var.vco_url
  edge_profile   = var.edge_profile
  vco_address    = var.vco_address
  vco_username   = var.vco_username
  vco_password   = var.vco_password
  }


output "velo_byol" {
  value = module.velo_byol[*]
  description = "Individual velo info, such as mgmt public IP, name and trusted IP"
}