job "elasticsearch" {
  datacenters = ["dc1"]
  type = "service"
  
  constraint {
      attribute = "${attr.unique.hostname}"
      value    = "nomad3"
    }

  group "elk-group" {
    count = 1

    task "elastic-task" {

      driver = "docker"

      config {
        image = "elasticsearch:7.14.1"
        network_mode = "host"
        port_map {
          elastic = 9200
          transport = 9300
        }
        volumes = ["local/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml"]
       }

      template {  
        data = <<EOH
          discovery.type: single-node
          network.host: 0.0.0.0
          http.port: 9200
          cluster.name: "docker-cluster"

          xpack.license.self_generated.type: trial
        EOH

        destination = "local/elasticsearch.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        memory = 2048
        cpu = 1000
        network {
        port "elastic" {
          static = 9200
         }
        port "transport" {
          static = 9300
         }
        }
      }
    }
  }
}
