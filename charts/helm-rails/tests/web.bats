#!/usr/bin/env bats

load helpers

@test "generates web deployment" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    services:
      web:
        containers:
          example:
            http: {}
YAML

  select_object 'Deployment' 'example-app-web'
  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/component' 'web'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
  select_json '.spec'
  assert_json '.replicas' 'null'
  assert_json '.selector.matchLabels["app.kubernetes.io/component"]' 'web'
  assert_json '.selector.matchLabels["app.kubernetes.io/instance"]' 'example-app-production'
  assert_json '.selector.matchLabels["app.kubernetes.io/name"]' 'example-app'
  select_json '.template'
  assert_label 'app.kubernetes.io/name' 'example-app'
  select_json '.spec'
  assert_json '.containers[0].envFrom[0].configMapRef.name' 'example-app-env'
  assert_json '.containers[0].name' 'example'
  assert_json '.containers[0].image' 'docker.io/example:abc123'
  assert_json '.containers[0].imagePullPolicy' 'IfNotPresent'
  assert_json '.containers[0].args[0]' 'rails'
  assert_json '.containers[0].args[1]' 'server'
  assert_json '.containers[0].ports[0].name' 'http'
  assert_json '.containers[0].ports[0].containerPort' '3000'
  assert_json '.containers[0].ports[0].protocol' 'TCP'
  assert_json '.containers[0].readinessProbe.httpGet.path' '/robots.txt'
}

@test "generates web deployment without autoscaling" {
  render <<-YAML
    app:
      name: "example-app"
    services:
      web:
        autoscaling:
          enabled: false
        containers:
          example:
            http: {}
YAML

  select_object 'Deployment' 'example-app-web'
  assert_json ".spec.replicas" "1"

  reset_selection
  assert_no_object 'HorizontalPodAutoscaler' 'example-app-web'
}

@test "generates web service" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      version: abc123
    services:
      web:
        containers:
          example:
            http: {}
YAML

  select_object 'Service' 'example-app-web'
  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/component' 'web'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
  select_json '.spec'
  assert_json '.ports[0].name' 'http'
  assert_json '.ports[0].port' '3000'
  assert_json '.ports[0].protocol' 'TCP'
  assert_json '.ports[0].targetPort' 'http'
  assert_json '.selector["app.kubernetes.io/component"]' 'web'
  assert_json '.selector["app.kubernetes.io/instance"]' 'example-app-production'
  assert_json '.selector["app.kubernetes.io/name"]' 'example-app'
  assert_json '.type' 'ClusterIP'
}

@test "generates without web resources when disabled" {
  render <<-YAML
    app:
      name: "example-app"
    services:
      web:
        enabled: false
YAML

  assert_no_object 'Deployment' 'example-app-web'
  assert_no_object 'Service' 'example-app-web'
}

@test "generates with only a custom web worker" {
  render <<-YAML
    app:
      name: "example-app"
    services:
      web:
        enabled: false
      custom:
        containers:
          rails:
            http: {}
YAML

  select_object 'Deployment' 'example-app-custom'
  assert_json '.metadata.namespace' 'default'
  assert_json '.spec.template.spec.containers[0].ports[0].name' 'http'
  select_object 'Service' 'example-app-custom'
  assert_json '.metadata.namespace' 'default'
  assert_no_object 'Deployment' 'example-app-web'
  assert_no_object 'Service' 'example-app-web'
}

@test "generates web deployment with autoscaling defaults" {
  render <<-YAML
    app:
      name: "example-app"
    services:
      web:
        autoscaling:
          enabled: true
        containers:
          example:
            http: {}
YAML

  select_object 'Deployment' 'example-app-web'
  assert_json ".spec.replicas" "null"

  reset_selection
  select_object 'HorizontalPodAutoscaler' 'example-app-web'
  assert_json '.metadata.namespace' 'default'
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

