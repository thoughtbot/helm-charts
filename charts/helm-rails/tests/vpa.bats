#!/usr/bin/env bats

load helpers

@test "creates a vertical pod autoscaler with defaults when enabled" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    defaults:
      container:
        containersizing:
          maxAllowed:
            cpu: 1000m
            memory: 2Gi
    services:
      web:
        autosizing:
          enabled: true
        containers:
          web:
            http: {}
YAML

  select_object 'VerticalPodAutoscaler' 'example-app-web'

  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/component' 'web'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'

  select_json '.spec'

  assert_json '.targetRef.apiVersion' 'apps/v1'
  assert_json '.targetRef.kind' 'Deployment'
  assert_json '.targetRef.name' 'example-app-web'

  # assert_json '.updatePolicy.minReplicas' '1'
  assert_json '.updatePolicy.updateMode' 'Auto'

  select_json '.resourcePolicy'

  assert_json '.containerPolicies[0].containerName' 'web'
  assert_json '.containerPolicies[0].maxAllowed.cpu' '1000m'
  assert_json '.containerPolicies[0].maxAllowed.memory' '2Gi'
}

@test "skips a vertical pod autoscaler when disabled" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    defaults:
      autosizing:
        enabled: false
YAML

  assert_no_object 'VerticalPodAutoscaler' 'example-app-web'
}

@test "creates a vertical pod autoscaler with custom options" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    containers:
      rails:
        containersizing:
          maxAllowed:
            cpu: 1000m
            memory: 2Gi
    services:
      web:
        autoscaling:
          enabled: true
          minReplicas: 3
        autosizing:
          enabled: true
          updatePolicy:
            updateMode: Initial
        containers:
          rails:
            http: {}
            containersizing:
              minAllowed:
                memory: 512Mi
              maxAllowed:
                cpu: 1500m
                memory: 2Gi
YAML

  select_object 'VerticalPodAutoscaler' 'example-app-web'

  assert_json '.metadata.namespace' 'default'
  select_json '.spec'

  assert_json '.targetRef.apiVersion' 'apps/v1'
  assert_json '.targetRef.kind' 'Deployment'
  assert_json '.targetRef.name' 'example-app-web'

  # assert_json '.updatePolicy.minReplicas' '3'
  assert_json '.updatePolicy.updateMode' 'Initial'

  select_json '.resourcePolicy'

  assert_json '.containerPolicies[0].containerName' 'rails'
  assert_json '.containerPolicies[0].maxAllowed.cpu' '1500m'
  assert_json '.containerPolicies[0].maxAllowed.memory' '2Gi'
  assert_json '.containerPolicies[0].minAllowed.memory' '512Mi'
}
