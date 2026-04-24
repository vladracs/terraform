# Copyright Palo Alto Networks Inc. 2025
#
# Sample resource example for "security_policy_global_prefix"
#
# To be able to use this template, first use the Prisma SDWAN provider:
# terraform {
#    required_providers {
#      prismasdwan = {
#        source  = "paloaltonetworks/terraform-provider-prismasdwan"
#        version = "a.b.c.d[-beta]"
#      }
#    }
#  }
#
#
# Configure the Provider with appropriate Service Account Credentials
#
#  provider "prismasdwan" {
#    host          = "api.sase.paloaltonetworks.com"
#    client_id     = "acmeuser@12345.iam.panserviceaccount.com"
#    client_secret = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
#    scope         = "tsg_id:12345"
#    auth_url      = "https://auth.apps.paloaltonetworks.com/am/oauth2/access_token"
#  }
#
#

resource "prismasdwan_security_policy_global_prefix" "corporate_security_global_prefix" {
  name          = "corporate_security_global_prefix"
  description = "Managed by Prisma SDWAN Terraform IaaC Provider"
  tags          = ["corporate", "security"]
  ipv4_prefixes = ["192.168.0.0/16"]
  ipv6_prefixes = ["2001:db8::/32"]
}

resource "prismasdwan_security_policy_global_prefix" "branch_office_security_global_prefix" {
  name          = "branch_office_security_global_prefix"
  description = "Managed by Prisma SDWAN Terraform IaaC Provider"
  tags          = ["branch", "security"]
  ipv4_prefixes = ["172.16.0.0/12"]
  ipv6_prefixes = ["2620:0:2d0::/48"]
}

resource "prismasdwan_security_policy_global_prefix" "data_center_security_global_prefix" {
  name          = "data_center_security_global_prefix"
  description = "Managed by Prisma SDWAN Terraform IaaC Provider"
  tags          = ["data_center", "security"]
  ipv4_prefixes = ["10.0.0.0/8"]
  ipv6_prefixes = ["2a00::/16"]
}
