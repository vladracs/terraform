# ---variable/module---

variable "sdwan_sub" {
  description = "Numbers of subnets to be deploy within a VPC"
  type        = number
}

variable "prod_sub" {
  description = "Numbers of subnets to be deploy within a VPC"
  type        = number
}

variable "dev_sub" {
  description = "Numbers of subnets to be deploy within a VPC"
  type        = number
}

variable "aws_secret_key_name" {
  type = string
  default = "AWS-VIRG-KEY"
}

variable "sdwan1_vpc_block" {
    type = string
    default = "10.231.44.0/24"
}

variable "sdwan1_pub_cidr_block" {
  type = list(string)
  default = [
    "10.231.44.0/28",
    "10.231.44.16/28"
  ]
}

variable "sdwan1_priv_cidr_block" {
  type = list(string)
  default = [
    "10.231.44.32/28",
    "10.231.44.48/28"
  ]
}



variable "dest_cidr"{
  default = "192.168.0.0/16"
}

variable "vpg_name" {
  description = "The name of the Customer Gateway"
  default     = "vpg_1"
}

variable "bgp_asn" {
  description = "The gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)"
  default     = 65010
}

variable "ip_address" {
  description = "The IP address of the gateway's Internet-routable external interface"
  default     = "1.2.3.4"
}

variable "type" {
  description = " The type of customer gateway. The only type AWS supports at this time is `ipsec.1`"
  default     = "ipsec.1"
}

variable "tags" {
  description = "Additional tags for the CGW"
  default     = {}

}

variable "ipv4_default" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ec2_server_type" {
  type    = string
  default = "t3.medium"
}
variable "ec2_linux_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_edge_type" {
  type    = string
  default = "c4.large"
}

variable "name_prefix" {
  type    = string
  default = "AWS-TEST-VCE-"
}

variable "ebs_root_size_in_gb" {
  type        = number
  default     = 16
  description = "the size in GB for the root disk"
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

variable "cidr_block" {
  type = string
}

