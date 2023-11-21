#---root/main---

resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "vmware-sase-branch-lab.pem"
  file_permission = "0600"
}


module "transit" {
  source    = "./vces"
  providers = {
    aws       = aws.us-east-1
    velocloud = velocloud.sdwan
  }
  sdwan_sub = 2
  prod_sub = 2
  dev_sub = 2
  vco_url        = var.vco_url
  edge_profile   = var.edge_profile
  vco_address    = var.vco_address
  vco_username   = var.vco_username
  vco_password   = var.vco_password
  cidr_block = var.cidr_block
}