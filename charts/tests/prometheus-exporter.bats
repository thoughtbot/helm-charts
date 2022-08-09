#!/usr/bin/env bats

load helpers

@test "adds a Prometheus Exporter sidecar" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    services:
      web:
        containers:
          main:
            http: {}
          prometheus-exporter: {}
YAML

  select_object 'Deployment' 'example-app-web'
  select_json '.spec'
  select_json '.template'
  select_json '.spec'
  assert_json '.containers[0].args[0]' 'rails'
  assert_json '.containers[0].args[1]' 'server'
  assert_json '.containers[0].ports[0].name' 'http'
  assert_json '.containers[1].args[2]' 'prometheus_exporter'
  assert_json '.containers[1].ports[0].name' 'metrics'
}
