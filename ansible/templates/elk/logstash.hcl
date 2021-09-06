job "logstash" {
  datacenters = ["dc1"]
  type = "service"
  
  constraint {
      attribute = "${attr.unique.hostname}"
      value    = "nomad3"
    }

  group "elk-group" {
    count = 1

    task "logstash-task" {

      driver = "docker"

      config {
        image = "docker.elastic.co/logstash/logstash:7.14.1"
        network_mode = "host"
        port_map {
          logstash = 5044
        }
        volumes = ["local/logstash.yml:/usr/share/logstash/config/logstash.yml","local/logstash.conf:/usr/share/logstash/pipeline/logstash.conf"]
       }


      template {  
        data = <<EOH
         http.host: "0.0.0.0"
         xpack.monitoring.elasticsearch.hosts: [ "http://192.168.2.13:9200" ]
        EOH

        destination = "local/logstash.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {  
        data = <<EOH
         input {
           beats {
             port => 5044 
           }
         }

         output {
           if [fields][service] == "docker" {
	         elasticsearch {
		       hosts => "192.168.2.13:9200"
		       ecs_compatibility => disabled
	         }
           }
         } 
        EOH

        destination = "local/logstash.conf"
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
        port "logstash" {
          static = 5044
         }
        }
      }
    }
  }
}
