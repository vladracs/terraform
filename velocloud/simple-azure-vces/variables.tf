variable "region" {
  type        = string
  description = "Provide region of the resources"
}

variable "zone" {
  type = number
  description = "Provide the Availability zone to deploy velo VM into"
}

variable "zones" {
  type = list
  description = "Provide list of Availability zone to deploy velo VM Public IP"
}
variable "resource_group_name" {
  type        = string
  description = "Provide Resoruce Group Name for velo"
}

variable "velo_vm_name" {
  type = string
  description = "Provide velo BYOL VM name"
}
variable "vco_edge_name" {
  type = string
  description = "Provide velo edge vco name"
}

variable "public_subnet_id" {
  type = string
  description = "Provide public subnet ID"
}

variable "trust_subnet_id" {
  type = string
  description = "Provide trust subnet ID"
}

variable "velo_size" {
  type = string
  description = "Provide velo VM Size"
}

variable "admin_username" {
  type = string
  description = "Provide velo default user name"
}
variable "admin_password" {
  type = string
  description = "Provide velo default password"
}

variable "velo_version" {
  type = string
  description = "Provide velo BYOL VM version"
}

variable "vco_address" {
  type = string
}

variable "vco_url" {
  type = string
}

variable "vco_username" {
  type = string
}

variable "vco_password" {
  type = string
}

variable "edge_profile" {
  type = string
}

variable "name_prefix" {
  type    = string
  default = "Azure-"
}