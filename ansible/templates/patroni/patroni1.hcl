job "patroni1" {
  datacenters = ["dc1"]
  type = "service"
  
  constraint {
      attribute = "${attr.unique.hostname}"
      value     = "nomad1"
    }

  group "patroni-group" {
    count = 1

    volume "fs" {
      type = "host"
      read_only = false
      source = "patroni"
    }

    task "patroni-tasks" {
      #volume_mount {
      #  volume = "fs"
      #  destination = "/data/patroni"
      #}
      driver = "docker"

      config {
        image = "tv1n94/patroni7"
        network_mode = "host"
      #  ports = ["db"]
        port_map {
          db = 5432
        }
        
      }

      env {
        PATRONI_API_CONNECT_PORT="8008"
        REPLICATION_NAME="replicator"
        REPLICATION_PASS="replicator"
        SU_NAME="postgres"
        SU_PASS="postgres"
        POSTGRES_APP_ROLE_PASS="postgres"
        PATRONI_CONSUL_URL="http://192.168.2.100:8500"
        IP_ADDR="${attr.unique.network.ip-address}"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        memory = 1024
        network {
        port "db" {
          static = 5432
         }
        }
      }

      service {
        name = "patroni1"
        tags = ["patroni", "postgresql"]
        port = "db"
        
        check {
          name     = "patroni1 port alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
     restart {
       attempts = 10
       interval = "5m"
       delay = "25s"
       mode = "delay"
    }
  }
}

