resource "ah_private_network" "example" {
  ip_range = "192.168.2.0/24"
  name     = "LAN for cluster1"
}

resource "ah_volume" "hdd-backup" {
    name        = "hdd-backup"
    product     = var.ah_hdd_backup
    file_system = "ext4"
    size        = "100"
}

resource "ah_cloud_server" "nomad" {
  count        = 3
  name         = "nomad${count.index + 1}"
  datacenter   = var.ah_dc
  image        = var.ah_image_type
  product      = var.ah_machine_type_nomad_client
  use_password = var.use_password
  ssh_keys     = ["YOUR_FINGERPRINT"]
  depends_on = [
    ah_private_network.example
  ]
}

resource "ah_private_network_connection" "nomad-client1" {
  count              = 3
  cloud_server_id    = ah_cloud_server.nomad[count.index].id
  private_network_id = ah_private_network.example.id
  ip_address         = "192.168.2.${count.index + 11}"
  depends_on = [
    ah_cloud_server.nomad,
    ah_private_network.example
  ]
}

resource "ah_cloud_server" "nomad-server" {
  count        = 3
  name         = "nomad-server${count.index + 1}"
  datacenter   = var.ah_dc
  image        = var.ah_image_type
  product      = var.ah_machine_type
  use_password = var.use_password
  ssh_keys     = ["YOUR_FINGERPRINT"]
  depends_on = [
    ah_private_network.example
  ]
}

resource "ah_private_network_connection" "nomad-server1" {
  count              = 3
  cloud_server_id    = ah_cloud_server.nomad-server[count.index].id
  private_network_id = ah_private_network.example.id
  ip_address         = "192.168.2.${count.index + 21}"
  depends_on = [
    ah_cloud_server.nomad-server,
    ah_private_network.example
  ]
}

resource "ah_cloud_server" "backup" {
  name         = "backup"
  datacenter   = var.ah_dc
  image        = var.ah_image_type
  product      = var.ah_machine_type
  use_password = var.use_password
  ssh_keys     = ["YOUR_FINGERPRINT"]
  depends_on = [
    ah_private_network.example,
  ]
}

resource "ah_private_network_connection" "backup1" {
  cloud_server_id    = ah_cloud_server.backup.id
  private_network_id = ah_private_network.example.id
  ip_address         = "192.168.2.30"
  depends_on = [
    ah_cloud_server.backup,
    ah_private_network.example
  ]
}

resource "ah_volume_attachment" "backup" {
  cloud_server_id = ah_cloud_server.backup.id
  volume_id       = ah_volume.hdd-backup.id
  depends_on = [
  ah_cloud_server.backup
  ]
}