resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.region
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "resource_group_region" {
  value = azurerm_resource_group.this.location
}

resource "azurerm_virtual_network" "this" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = var.vnet_name
  address_space       = [var.vnet_cidr]
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

resource "azurerm_subnet" "public" {
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  name                 = "public"
  address_prefixes     = [var.public_cidr]
}

resource "azurerm_subnet" "trust" {
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  name                 = "Trust"
  address_prefixes     = [var.trust_cidr]
}

resource "azurerm_network_security_group" "default_nsg" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "DefaultNSG"

  security_rule {
    access                     = "Deny"
    description                = "Default-Deny if we don't match Allow rule"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "Default-Deny"
    priority                   = 200
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    description                = "Allow intra network traffic"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "Allow-Intra"
    priority                   = 102
    protocol                   = "*"
    source_address_prefix      = var.vnet_cidr
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    description                = "Allow SSH access"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    direction                  = "Inbound"
    name                       = "Allow-SSH-Outside"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
  }

    security_rule {
    access                     = "Allow"
    description                = "Allow VCMP in"
    destination_address_prefix = "*"
    destination_port_range     = "2426"
    direction                  = "Inbound"
    name                       = "Allow-VCMP-UDP-Outside"
    priority                   = 100
    protocol                   = "Udp"
    source_port_range          = "*"
    source_address_prefix      = "*"
  }
}



resource "azurerm_subnet_network_security_group_association" "default_nsg_association" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.default_nsg.id
}
