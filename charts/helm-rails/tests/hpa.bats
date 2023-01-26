#!/usr/bin/env bats

load helpers

@test "creates a horizontal pod autoscaler with defaults when enabled" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    defaults:
      autoscaling:
        enabled: true
    services:
      web:
        containers:
          rails:
            http: {}
YAML

  select_object 'HorizontalPodAutoscaler' 'example-app-web'

  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/component' 'web'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'

  select_json '.spec'

  assert_json '.minReplicas' '1'
  assert_json '.maxReplicas' '5'

  assert_json '.metrics[0].type' 'Resource'
  assert_json '.metrics[0].resource.name' 'cpu'
  assert_json '.metrics[0].resource.target.averageUtilization' '65'

  assert_json '.scaleTargetRef.apiVersion' 'apps/v1'
  assert_json '.scaleTargetRef.kind' 'Deployment'
  assert_json '.scaleTargetRef.name' 'example-app-web'
}

@test "skips a horizontal pod autoscaler when disabled" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    defaults:
      autoscaling:
        enabled: false
YAML

  assert_no_object 'HorizontalPodAutoscaler' 'example-app-web'
}

@test "creates a horizontal pod autoscaler with custom options" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    services:
      web:
        autoscaling:
          enabled: true
          minReplicas: 3
          maxReplicas: 6
          behavior:
            scaleUp:
              policies:
              - type: Percent
                value: 25
                periodSeconds: 120
          metrics:
          - type: Object
            object:
              metric:
                name: ruby_http_queue_duration_seconds_95p1m
              describedObject:
                apiVersion: v1
                kind: Service
              target:
                type: Value
                value: 50m
YAML

  select_object 'HorizontalPodAutoscaler' 'example-app-web'

  assert_json '.metadata.namespace' 'default'
  select_json '.spec'

  assert_json '.minReplicas' '3'
  assert_json '.maxReplicas' '6'

  assert_json '.behavior.scaleUp.policies[0].type' 'Percent'

  assert_json '.metrics[0].type' 'Object'
  assert_json '.metrics[0].object.metric.name' 'ruby_http_queue_duration_seconds_95p1m'
  assert_json '.metrics[0].object.describedObject.name' 'example-app-web'
}
