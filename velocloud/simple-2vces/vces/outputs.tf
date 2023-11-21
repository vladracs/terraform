# #---module/output---
output "vcourl" {
  value = "${var.vco_url}"
}

output "vce-1a_public_ip" {
  value = aws_eip.vce-1a_wan1_eip
}
output "vce-1a_actkey" {
  value = "${velocloud_edge.vce-1a.activationkey}"
}
