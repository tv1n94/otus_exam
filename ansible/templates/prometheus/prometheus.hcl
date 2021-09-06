job "prometheus" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
      attribute = "${attr.unique.hostname}"
      value     = "nomad3"
    }

  group "monitoring" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 1000
    }

    task "prometheus" {
      template {
        change_mode = "noop"
        destination = "local/alerts.yml"
        data = <<EOH
---
groups:
- name: prometheus_alerts
  rules:
  - alert: LB
    expr: absent(up{job="lb"})
    for: 10s
    labels:
      severity: critical
    annotations:
      description: "Our load balancer is down."

  - alert: Patroni1
    expr: absent(up{job="patroni1"})
    for: 10s
    labels:
      severity: critical
    annotations:
      description: "Patroni1 is down."

  - alert: Patroni2
    expr: absent(up{job="patroni2"})
    for: 10s
    labels:
      severity: critical
    annotations:
      description: "Patroni2 is down."

  - alert: Pgbouncer
    expr: absent(up{job="pgbouncer"})
    for: 10s
    labels:
      severity: critical
    annotations:
      description: "Pgbouncer is down."

  - alert: Nextcloud1
    expr: absent(up{job="nextcloud1"})
    for: 10s
    labels:
      severity: critical
    annotations:
      description: "Nextcloud1 is down."

  - alert: Nextcloud2
    expr: absent(up{job="nextcloud2"})
    for: 10s
    labels:
      severity: critical
    annotations:
      description: "Nextcloud2 is down."


EOH
      }

      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"
        data = <<EOH
---
global:
  scrape_interval:     5s
  evaluation_interval: 5s

alerting:
  alertmanagers:
  - consul_sd_configs:
    - server: '192.168.2.100:8500'
      services: ['alertmanager']

rule_files:
  - "alerts.yml"

scrape_configs:

  - job_name: 'alertmanager'

    consul_sd_configs:
    - server: '192.168.2.100:8500'
      services: ['alertmanager']

  - job_name: 'nomad_metrics'

    consul_sd_configs:
    - server: '192.168.2.100:8500'
      services: ['nomad-client', 'nomad']

    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep

    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']

  - job_name: 'lb'

    consul_sd_configs:
    - server: '192.168.2.100:8500'
      services: ['lb']

  - job_name: 'patroni1'
  
    consul_sd_configs:
    - server: '192.168.2.100:8500'
      services: ['patroni1']

  - job_name: 'patroni2'
  
    consul_sd_configs:
    - server: '192.168.2.100:8500'
      services: ['patroni2']

  - job_name: 'pgbouncer'
  
    consul_sd_configs:
    - server: '192.168.2.100:8500'
      services: ['pgbouncer']

  - job_name: 'nextcloud1'
  
    consul_sd_configs:
    - server: '192.168.2.100:8500'
      services: ['nextcloud1']

  - job_name: 'nextcloud2'
  
    consul_sd_configs:
    - server: '192.168.2.100:8500'
      services: ['nextcloud2']

    metrics_path: /metrics
EOH
      }
      driver = "docker"
      config {
        image = "prom/prometheus:latest"
        volumes = [
          "local/alerts.yml:/etc/prometheus/alerts.yml",
          "local/prometheus.yml:/etc/prometheus/prometheus.yml"
        ]
        port_map {
          prometheus_ui = 9090
        }
      }
      resources {
        network {
          mbits = 10
          port "prometheus_ui" {}
        }
      }
      service {
        name = "prometheus"
        tags = ["urlprefix-/"]
        port = "prometheus_ui"
        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
