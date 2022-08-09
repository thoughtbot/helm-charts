#!/usr/bin/env bats

load helpers

@test "generates sidekiq deployments" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    services:
      web:
        enabled: false
      default-worker:
        containers:
          rails:
            sidekiq:
              queues:
              - default,10
              - mailers,1
              concurrency: 5
      reports:
        containers:
          rails:
            sidekiq:
              queues:
              - reports
              concurrency: 1
YAML

  select_object 'Deployment' 'example-app-default-worker'
  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/component' 'default-worker'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
  select_json '.spec'
  assert_json '.replicas' 'null'
  assert_json '.selector.matchLabels["app.kubernetes.io/component"]' 'default-worker'
  assert_json '.selector.matchLabels["app.kubernetes.io/instance"]' 'example-app-production'
  assert_json '.selector.matchLabels["app.kubernetes.io/name"]' 'example-app'
  select_json '.template'
  assert_label 'app.kubernetes.io/name' 'example-app'
  select_json '.spec'
  assert_json '.containers[0].args[0]' 'sidekiq'
  assert_json '.containers[0].args[1]' '-q'
  assert_json '.containers[0].args[2]' 'default,10'
  assert_json '.containers[0].args[3]' '-q'
  assert_json '.containers[0].args[4]' 'mailers,1'
  assert_json '.containers[0].args[5]' '-c'
  assert_json '.containers[0].args[6]' '5'
  assert_json '.containers[0].envFrom[0].configMapRef.name' 'example-app-env'
  assert_json '.containers[0].name' 'rails'
  assert_json '.containers[0].image' 'docker.io/example:abc123'
  assert_json '.containers[0].imagePullPolicy' 'IfNotPresent'
  assert_json '.containers[0].ports[0].name' 'null'

  reset_selection
  select_object 'Deployment' 'example-app-reports'
  select_json '.spec'
  select_json '.template'
  select_json '.spec'
  assert_json '.containers[0].args[0]' 'sidekiq'
  assert_json '.containers[0].args[1]' '-q'
  assert_json '.containers[0].args[2]' 'reports'
  assert_json '.containers[0].args[3]' '-c'
  assert_json '.containers[0].args[4]' '1'
}

@test "generates sidekiq services" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      version: abc123
    services:
      web:
        enabled: false
      default-worker:
        containers:
          rails:
            http: {}
            sidekiq: {}
YAML

  select_object 'Service' 'example-app-default-worker'
  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/component' 'default-worker'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
  select_json '.spec'
  # assert_json '.ports[0]' 'null'
  assert_json '.ports[0].name' 'http'
  assert_json '.ports[0].port' '3000'
  assert_json '.ports[0].protocol' 'TCP'
  assert_json '.ports[0].targetPort' 'http'
  assert_json '.selector["app.kubernetes.io/component"]' 'default-worker'
  assert_json '.selector["app.kubernetes.io/instance"]' 'example-app-production'
  assert_json '.selector["app.kubernetes.io/name"]' 'example-app'
  # assert_json '.type' 'None'
  assert_json '.type' 'ClusterIP'
}
