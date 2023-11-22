
output "vce_public_ips" {
  value = "${azurerm_public_ip.public_pip.ip_address}"
}

output "velo_name" {
  value = var.velo_vm_name
}

output "admin_username__may_change_by_bootstrap" {
  value = var.admin_username
}

output "admin_password__may_change_by_bootstrap" {
  value = var.admin_password
}

output "trust_ip" {
  value = azurerm_network_interface.trust.private_ip_address
}
