job "kibana" {
  datacenters = ["dc1"]
  type = "service"
  
  constraint {
      attribute = "${attr.unique.hostname}"
      value    = "nomad3"
    }

  group "elk-group" {
    count = 1

    task "kibana-task" {

      driver = "docker"

      config {
        image = "kibana:7.14.1"
        network_mode = "host"
        port_map {
          kibana = 5601
        }
        volumes = ["local/kibana.yml:/usr/share/kibana/config/kibana.yml"]
       }


      template {  
        data = <<EOH
        server.name: kibana
        server.host: "0.0.0.0"
        elasticsearch.hosts: [ "http://192.168.2.13:9200" ]
        monitoring.ui.container.elasticsearch.enabled: true
        EOH

        destination = "local/kibana.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        memory = 1024
        cpu = 500
        network {
        port "kibana" {
          static = 5601
         }
        }
      }
    }
  }
}
