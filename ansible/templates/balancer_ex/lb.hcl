job "lb" {
  datacenters = ["dc1"]
  type = "service"
  
constraint {
    attribute = "${attr.unique.hostname}"
    value     = "nomad3"
    }

  group "lb" {
    count = 1

    task "lb-task" {

      driver = "docker"

      config {
        image = "nginx"
        network_mode = "host"
        port_map {
          lb = 80
        }
        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
upstream backend {
  ip_hash;
    server 192.168.2.11:80 max_fails=2 fail_timeout=5s;
    server 192.168.2.12:80 max_fails=2 fail_timeout=5s;
}

server {
   listen 80;

   location / {
      proxy_pass http://backend;
   }
}
EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
        
      resources {
        memory = 512
        network {
        port "lb" {
          static = 80
         }
        }
      }
      service {
        name = "lb"
        tags = ["nginx"]
        #port = "lb"
        
        check {
         type     = "http"
         port     = "lb"
         path     = "/"
         interval = "60s"
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
