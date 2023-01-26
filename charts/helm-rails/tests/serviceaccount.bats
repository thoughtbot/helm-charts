#!/usr/bin/env bats

load helpers

@test "creates a serviceaccount when enabled" {
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
      - name: default
        serviceaccount:
          example-app-web:
            create: true
            iamrolearn: arn:aws:iam::000000000000:role/example
YAML

  select_object 'ServiceAccount' 'example-app-web'

  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
}

@test "uses an existing service account with creation disabled" {
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
      - name: default
        serviceaccount:
          example-app-web:
            create: false
YAML

  assert_no_object 'ServiceAccount' 'example-app-web'
  select_object 'Deployment' 'example-app-web'
  assert_json '.spec.template.spec.serviceAccountName' 'example-app-web'
}

@test "skips a serviceaccount when disabled" {
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
      - name: default
YAML

  assert_no_object 'ServiceAccount' 'example-app-web'
  select_object 'Deployment' 'example-app-web'
  assert_json '.spec.template.spec.serviceAccountName' 'null'
}
