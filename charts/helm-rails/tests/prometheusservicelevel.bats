#!/usr/bin/env bats

load helpers

@test "adds slo definitions" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    services:
      web:
        containers:
          rails:
            http: {}
        prometheusservicelevel:
          enabled: true
          availability:
            objective: 99.9
          latency:
            - name: HTTPLatency99th
              objective: 99
              target: 20000
            - name: HTTPLatency95th
              objective: 95
              target: 750
YAML

  select_object 'PrometheusServiceLevel' 'example-app-default-slos'
  select_json '.spec'
  assert_json '.slos[0].name' 'example-app-default-web-requests-availability'
  assert_json '.slos[0].objective' '99.9'

  assert_json '.slos[1].name' 'example-app-default-requests-99-latency'
  assert_json '.slos[1].objective' '99'
  assert_json '.slos[1].sli.events.errorQuery' 'sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name="example-app-web"}[5m])))[{{.window}}:5m]) - sum_over_time((sum(rate(istio_request_duration_milliseconds_bucket{destination_service_name="example-app",le="20000"}[5m])))[{{.window}}:5m])'
  assert_json '.slos[1].sli.events.totalQuery' 'sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name="example-app-web"}[5m])))[{{.window}}:5m]) > 0'
  
  assert_json '.slos[2].name' 'example-app-default-requests-95-latency'
  assert_json '.slos[2].objective' '95'
  assert_json '.slos[2].sli.events.errorQuery' 'sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name="example-app-web"}[5m])))[{{.window}}:5m]) - sum_over_time((sum(rate(istio_request_duration_milliseconds_bucket{destination_service_name="example-app",le="750"}[5m])))[{{.window}}:5m])'
  assert_json '.slos[2].sli.events.totalQuery' 'sum_over_time((sum(rate(istio_request_duration_milliseconds_count{destination_service_name="example-app-web"}[5m])))[{{.window}}:5m]) > 0'
}
