resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tpl",
    {
      ip1 = ah_cloud_server.nomad.*.ips.0.ip_address
      ip2 = ah_cloud_server.nomad-server.*.ips.0.ip_address
      ip3 = ah_cloud_server.backup.ips.0.ip_address
      #ip4 = ah_cloud_server.lb.ips.0.ip_address
    }
  )
  filename = "hosts"

  provisioner "local-exec" {
    command = "ansible-playbook -i hosts  ansible/provision.yml -u adminroot -e 'ansible_python_interpreter=/usr/bin/python3'"
   }
}