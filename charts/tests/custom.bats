#!/usr/bin/env bats

load helpers

@test "generates custom deployment" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    services:
      reaper:
        containers:
          main:
            args:
            - rails
            - reaper
YAML

  select_object 'Deployment' 'example-app-reaper'
  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/component' 'reaper'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
  select_json '.spec'
  assert_json '.replicas' 'null'
  assert_json '.selector.matchLabels["app.kubernetes.io/component"]' 'reaper'
  assert_json '.selector.matchLabels["app.kubernetes.io/instance"]' 'example-app-production'
  assert_json '.selector.matchLabels["app.kubernetes.io/name"]' 'example-app'
  select_json '.template'
  assert_label 'app.kubernetes.io/name' 'example-app'
  select_json '.spec'
  assert_json '.containers[0].envFrom[0].configMapRef.name' 'example-app-env'
  assert_json '.containers[0].name' 'main'
  assert_json '.containers[0].image' 'docker.io/example:abc123'
  assert_json '.containers[0].imagePullPolicy' 'IfNotPresent'
  assert_json '.containers[0].args[0]' 'rails'
  assert_json '.containers[0].args[1]' 'reaper'
}

@test "generates custom service" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      image: docker.io/example
      version: abc123
    services:
      reaper:
        containers:
          main:
            http: {}
            args:
            - rails
            - reaper
YAML

  select_object 'Service' 'example-app-reaper'
  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/component' 'reaper'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
  select_json '.spec'
  assert_json '.selector["app.kubernetes.io/component"]' 'reaper'
  assert_json '.selector["app.kubernetes.io/instance"]' 'example-app-production'
  assert_json '.selector["app.kubernetes.io/name"]' 'example-app'
  # assert_json '.type' 'None'
}
