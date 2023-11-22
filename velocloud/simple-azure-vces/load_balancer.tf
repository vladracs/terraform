resource "azurerm_lb" "this" {
  name                = "${var.velo_vm_name}-lb"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  frontend_ip_configuration {
    name                          = "LoadBalancerFrontEnd"
    subnet_id                     = azurerm_subnet.trust.id
    private_ip_address_allocation = "Dynamic"
  }
  sku = "Standard"
  sku_tier = "Regional"
}

resource "azurerm_lb_probe" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "sshprobe"
  protocol        = "Tcp"
  port            = 22
  interval_in_seconds = 5
}

resource "azurerm_lb_backend_address_pool" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "backendpool"
}

resource "azurerm_lb_rule" "this" {
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "LBRule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.this.id]
  probe_id = azurerm_lb_probe.this.id
}

resource "azurerm_lb_backend_address_pool_address" "this" {
  count = length(module.velo_byol)
  name                    = "${var.velo_vm_name}-${count.index+1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
  virtual_network_id      = azurerm_virtual_network.this.id
  ip_address              = module.velo_byol[count.index].trust_ip
}

output "ilb_ip" {
  value = azurerm_lb.this.frontend_ip_configuration[0].private_ip_address
  description = "Internal Load Balancer's private IP address"
}
