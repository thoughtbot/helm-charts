#!/usr/bin/env bats

load helpers

@test "creates a namespace when enabled" {
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
    namespaces:
      - name: example
        create: true
YAML

  select_object 'Namespace' 'example'

  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
}

@test "skips a namespace when disabled" {
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
    namespaces:
      - name: example
        create: false
YAML

  assert_no_object 'Namespace' 'example'
  assert_no_object 'Namespace' 'default'
}
