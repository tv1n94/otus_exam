output "nomad-clients" {
  value = ah_cloud_server.nomad.*.ips.0.ip_address
}

output "nomad-servers" {
  value = ah_cloud_server.nomad-server.*.ips.0.ip_address
}

output "backup1" {
  value = ah_cloud_server.backup.ips.0.ip_address
}

output "nextcloud_web" {
  value = ah_cloud_server.nomad.2.ips.0.reverse_dns
}
#output "backup" {
#  value = ah_cloud_server.backup.ips.0.ip_address
#}