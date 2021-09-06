job "nextcloud2" {
  datacenters = ["dc1"]
  type = "service"
  
  constraint {
      attribute = "${attr.unique.hostname}"
      value     = "nomad2"
    }

  group "nextcloud-group" {
    count = 1

    volume "fs" {
      type = "host"
      read_only = false
      source = "nextcloud"
    }

    volume "fs1" {
      type = "host"
      read_only = false
      source = "nextcloud_config"
    }


    task "nextcloud-tasks" {
      volume_mount {
        volume = "fs"
        destination = "/var/www/html/data"
      }

      volume_mount {
        volume = "fs1"
        destination = "/var/www/html/config"
      }

      driver = "docker"

      config {
        image = "nextcloud"
        network_mode = "host"
        
      }


      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
       cpu =  1000
       memory = 4096
       network {
        port "http" {
          static = 80
         }
        }   
      }

      service {
        name = "nextcloud2"
        tags = ["nextcloud"]

       check {
         type     = "http"
         port     = "http"
         path     = "/"
         interval = "30s"
         timeout  = "5s"
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
