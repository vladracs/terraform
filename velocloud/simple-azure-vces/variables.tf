variable "region" {
  type        = string
  default     = "East US"
  description = "Provide region of the resources"
}

variable "availability_zones" {
  type = list
  default = [1,2,3]
  description = "Provide list of Availability zones of the region to deploy velo VM into, it must include all zones, otherwise will cause public IP to gets recreated."
}

variable "resource_group_name" {
  type        = string
  default     = "velo-byol"
  description = "Provide Resoruce Group Name for velo"
}

variable "vnet_name" {
  type        = string
  default     = "velo-vnet"
  description = "Provide vNet name for velo"
}

variable "vnet_cidr" {
  type        = string
  default     = "10.0.16.0/24"
  description = "Provide vNet address space"
}

variable "mgmt_cidr" {
  type        = string
  default     = "10.0.16.0/26"
  description = "Provide mgmt subnet CIDR"
}

variable "public_cidr" {
  type        = string
  default     = "10.0.16.64/26"
  description = "Provide public (WAN) subnet CIDR"
}

variable "trust_cidr" {
  type        = string
  default     = "10.0.16.128/26"
  description = "Provide trust (LAN) subnet CIDR"
}

variable "velo_vm_count" {
  type = number
  default = 2
  description = "Provide total number of velo VM to be deployed"
}
variable "velo_vm_name" {
  type = string
  default = "velo-byol-vm"
  description = "Provide velo BYOL VM name"
}

variable "vco_edge_name" {
  type = string
  default = "vce"
  description = "Provide velo edge name in the VCO"
}

variable "velo_version" {
  type = string
  default = "10.1.4"
  description = "Provide velo BYOL VM version"
}

variable "velo_size" {
  type = string
  default = "Standard_D2d_v4"
  description = "Provide velo VM Size"
}

variable "admin_username" {
  type = string
  default = "veloadmin"
  description = "Provide velo default user name"
}
variable "admin_password" {
  type = string
  default = "Velocloud123!"
  description = "Provide velo default password"
}

#Velo Variables
variable "vco_address" {
  type = string
}

variable "vco_username" {
  type = string
}

variable "vco_password" {
  type = string
}

variable "vco_url" {
  type = string
}

variable "edge_profile" {
  type = string
}

