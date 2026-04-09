terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --- Variables (No Semicolons!) ---
variable "license_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "vion_password" {
  type      = string
  sensitive = true
}

variable "admin_user" {
  type    = string
  default = "vionadmin"
}

# --- Infrastructure ---
resource "azurerm_resource_group" "vion_rg" {
  name     = "vf_rg_tf_sdwan"
  location = "East US"
}
# --- (Keep Provider and Resource Group as is) ---

# --- Infrastructure ---
resource "azurerm_virtual_network" "vion_vnet" {
  name                = "CGNXVNET"
  address_space       = ["10.5.0.0/16"]
  location            = azurerm_resource_group.vion_rg.location
  resource_group_name = azurerm_resource_group.vion_rg.name
}

# Subnets exactly as per ARM
resource "azurerm_subnet" "controller" {
  name                 = "Controller"
  resource_group_name  = azurerm_resource_group.vion_rg.name
  virtual_network_name = azurerm_virtual_network.vion_vnet.name
  address_prefixes     = ["10.5.0.0/24"]
}

resource "azurerm_subnet" "wan1" {
  name                 = "Internet-1"
  resource_group_name  = azurerm_resource_group.vion_rg.name
  virtual_network_name = azurerm_virtual_network.vion_vnet.name
  address_prefixes     = ["10.5.1.0/24"]
}

resource "azurerm_subnet" "lan" {
  name                 = "LAN"
  resource_group_name  = azurerm_resource_group.vion_rg.name
  virtual_network_name = azurerm_virtual_network.vion_vnet.name
  address_prefixes     = ["10.5.2.0/24"]
}

resource "azurerm_subnet" "wan2" {
  name                 = "Internet-2"
  resource_group_name  = azurerm_resource_group.vion_rg.name
  virtual_network_name = azurerm_virtual_network.vion_vnet.name
  address_prefixes     = ["10.5.3.0/24"]
}

# --- Public IPs (Standard SKU as per ARM) ---
resource "azurerm_public_ip" "pip_ctrl" {
  name                = "vion-pip-controller"
  location            = azurerm_resource_group.vion_rg.location
  resource_group_name = azurerm_resource_group.vion_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip_wan1" {
  name                = "vion-pip-wan1"
  location            = azurerm_resource_group.vion_rg.location
  resource_group_name = azurerm_resource_group.vion_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# --- Network Interfaces (Aligning with ARM IDs 0, 1, 2, 3) ---

resource "azurerm_network_interface" "nic_0_controller" {
  name                = "vion-eth0"
  location            = azurerm_resource_group.vion_rg.location
  resource_group_name = azurerm_resource_group.vion_rg.name

  ip_configuration {
    name                          = "ipconfig-mgmt"
    subnet_id                     = azurerm_subnet.controller.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_ctrl.id
  }
}

resource "azurerm_network_interface" "nic_1_wan1" {
  name                  = "vion-eth1"
  location              = azurerm_resource_group.vion_rg.location
  resource_group_name   = azurerm_resource_group.vion_rg.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig-untrust-1"
    subnet_id                     = azurerm_subnet.wan1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.5.1.10" # Matched ARM
    public_ip_address_id          = azurerm_public_ip.pip_wan1.id
  }
}

resource "azurerm_network_interface" "nic_2_lan" {
  name                  = "vion-eth2"
  location              = azurerm_resource_group.vion_rg.location
  resource_group_name   = azurerm_resource_group.vion_rg.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig-trust-1"
    subnet_id                     = azurerm_subnet.lan.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_3_wan2" {
  name                  = "vion-eth3"
  location              = azurerm_resource_group.vion_rg.location
  resource_group_name   = azurerm_resource_group.vion_rg.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig-untrust-2"
    subnet_id                     = azurerm_subnet.wan2.id
    private_ip_address_allocation = "Dynamic"
  }
}

# --- vION 7108 VM ---
resource "azurerm_linux_virtual_machine" "vion" {
  name                            = "Prisma-SD-WAN-vION"
  resource_group_name             = azurerm_resource_group.vion_rg.name
  location                        = azurerm_resource_group.vion_rg.location
  size                            = "Standard_D8s_v3" # Matched ARM
  admin_username                  = var.admin_user
  admin_password                  = var.vion_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic_0_controller.id,
    azurerm_network_interface.nic_1_wan1.id,
    azurerm_network_interface.nic_2_lan.id,
    azurerm_network_interface.nic_3_wan2.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "prisma-sd-wan-ion-virtual-appliance"
    sku       = "prisma-sdwan-ion-virtual-appliance"
    version   = "latest"
  }

  plan {
    name      = "prisma-sdwan-ion-virtual-appliance"
    product   = "prisma-sd-wan-ion-virtual-appliance"
    publisher = "paloaltonetworks"
  }

  # THE BOOTSTRAP: 1:1 MATCH OF ARM CONCAT LOGIC
  custom_data = base64encode(<<-EOF
[General]
model = ion 7108v
host1_name = locator.cgnx.net

[License]
key = ${var.license_key}
secret = ${var.secret_key}

[Controller 1]
type = DHCP

[1]
role = PublicWAN
type = STATIC
address = 10.5.1.4/24
gateway = 10.5.1.1
dns1 = 8.8.8.8
[2]
role = LAN
type = STATIC
address = 10.5.2.4/24
gateway = 10.5.2.1
dns1 = 8.8.8.8
[3]
role = PublicWAN
type = STATIC
address = 10.5.3.4/24
gateway = 10.5.3.1
dns1 = 8.8.8.8
EOF
  )
}
