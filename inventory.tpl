[nomad_clients]
nomad1 ansible_host=${ip1[0]} ansible_name=nomad1 local_ip=192.168.2.11
nomad2 ansible_host=${ip1[1]} ansible_name=nomad2 local_ip=192.168.2.12
nomad3 ansible_host=${ip1[2]} ansible_name=nomad3 local_ip=192.168.2.13

[nomad_servers]
nomad-server1 ansible_host=${ip2[0]} ansible_name=nomad-server1 local_ip=192.168.2.21 priority=100 state=MASTER
nomad-server2 ansible_host=${ip2[1]} ansible_name=nomad-server2 local_ip=192.168.2.22 priority=200 state=BACKUP
nomad-server3 ansible_host=${ip2[2]} ansible_name=nomad-server3 local_ip=192.168.2.23 priority=200 state=BACKUP

[other]
backup1 ansible_host=${ip3} ansible_name=backup1 local_ip=192.168.2.30