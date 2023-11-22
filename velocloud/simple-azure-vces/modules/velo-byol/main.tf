resource "azurerm_public_ip" "public_pip" {
  resource_group_name = var.resource_group_name
  location            = var.region
  name                = "${var.velo_vm_name}-public-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones = var.zones
}

resource "azurerm_network_interface" "public" {
  resource_group_name = var.resource_group_name
  location            = var.region
  name                = "${var.velo_vm_name}-eth1"
  ip_configuration {
    name                          = "ipconfig-public"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.public_subnet_id
    public_ip_address_id          = azurerm_public_ip.public_pip.id
  }
  enable_ip_forwarding = false
}

resource "azurerm_network_interface" "trust" {
  resource_group_name = var.resource_group_name
  location            = var.region
  name                = "${var.velo_vm_name}-eth2"
  ip_configuration {
    name                          = "ipconfig-trust"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.trust_subnet_id
  }
  enable_ip_forwarding = true
}

### vce-1A VCO CONFIG
data "velocloud_profile" "edge_profile" {
  name = var.edge_profile
}

resource "velocloud_edge" "vce" {
  configurationid = data.velocloud_profile.edge_profile.id
  modelnumber     = "virtual"
  name            = "${var.vco_edge_name}"
  site {
    name         = "${var.vco_edge_name}"
    contactname  = "VMware SASE Branch Lab"
    contactemail = "vmware_sase_branch_lab@velocloud.net"
  }
}

resource "azurerm_linux_virtual_machine" "velo_byol" {
  name                = var.velo_vm_name
  resource_group_name = var.resource_group_name
  location            = var.region
  size                = var.velo_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zone                = var.zone

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("azure-key.pub")
  }
  
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.public.id,
    azurerm_network_interface.trust.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "vmware-inc"
    offer     = "sol-42222-bbj"
    sku       = "vmware_sdwan_501x"
    version   = "latest"
  }
  plan {
    name      = "vmware_sdwan_501x"
    product   = "sol-42222-bbj"
    publisher = "vmware-inc"
  }
  custom_data = base64encode(templatefile("${path.module}/templates/vce_userdata.yaml", {
    activation_code = "${velocloud_edge.vce.activationkey}"
    vco_url         = "${var.vco_url}"
  }))
}
