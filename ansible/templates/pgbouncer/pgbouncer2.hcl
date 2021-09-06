job "pgbouncer2" {
  datacenters = ["dc1"]
  type = "service"
  
  constraint {
      attribute = "${attr.unique.hostname}"
      value     = "nomad2"
    }

  group "patroni-group" {
    count = 1

    task "pgbouncer-task" {

      driver = "docker"

      config {
        image = "bitnami/pgbouncer:latest"
        network_mode = "host"
        
         volumes = ["local/pgbouncer.ini:/bitnami/pgbouncer/conf/pgbouncer.ini"]
       }

      env {
        POSTGRESQL_USERNAME="nextcloud"
        POSTGRESQL_PASSWORD="nextcloud"
        POSTGRESQL_DATABASE="nextcloud"
        POSTGRESQL_HOST="${attr.unique.network.ip-address}"
        POSTGRESQL_PORT="5432"
        PGBOUNCER_PORT="6432"
        PGBOUNCER_BIND_ADDRESS="0.0.0.0"
      }

      template {  
        data = <<EOH
        [databases]
        * = host={{ key "service/patroni/leader" }} port=5432

        [pgbouncer]
        listen_port=6432
      	listen_addr=0.0.0.0
      	auth_type=md5
      	auth_file=/opt/bitnami/pgbouncer/conf/userlist.txt
      	pidfile=/opt/bitnami/pgbouncer/tmp/pgbouncer.pid
      	logfile=/opt/bitnami/pgbouncer/logs/pgbouncer.log
      	admin_users=postgres
      	stats_users = stats, postgres
      	pool_mode = transaction
      	server_reset_query = DISCARD ALL
      	ignore_startup_parameters = extra_float_digits
      	max_client_conn = 5000
      	default_pool_size = 100
        EOH

        destination = "local/pgbouncer.ini"
        change_mode   = "restart"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        memory = 256
        network {
        port "pgbouncer2" {
          static = 6432
         }
        }
      }
      service {
        name = "pgbouncer2"
        tags = ["pgbouncer", "postgresql"]
        port = "pgbouncer2"
        
        check {
          name     = "pgbouncer2 port alive"
          type     = "tcp"
          interval = "60s"
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
