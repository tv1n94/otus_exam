job "nextcloud" {
  datacenters = ["dc1"]
  type = "service"
  
  constraint {
      attribute = "${attr.unique.hostname}"
      operator = "!="
      value    = "nomad3"
    }

  group "nextcloud-group" {
    count = 2

    volume "fs" {
      type = "host"
      read_only = false
      source = "nextcloud"
    }

    task "nextcloud-tasks" {
      volume_mount {
        volume = "fs"
        destination = "/var/www/html/data"
      }
      driver = "docker"

      config {
        image = "nextcloud"
        network_mode = "host"
        
      }

      env {
        POSTGRES_DB="nextcloud"
        POSTGRES_USER="nextcloud"
        POSTGRES_PASSWORD="nextcloud" 
        POSTGRES_HOST="127.0.0.1:6432"
        NEXTCLOUD_ADMIN_USER="otus-${attr.unique.hostname}"
        NEXTCLOUD_ADMIN_PASSWORD="OtusNextQAZ!"
        NEXTCLOUD_TRUSTED_DOMAINS="'*'"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      #resources {
      #  memory = 4096
      #}
    }
  }
}