#!/usr/bin/env bats

load helpers

@test "generates env config" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      version: abc123
    config:
      env:
        data:
          EXAMPLE: okay
YAML

  select_object 'ConfigMap' 'example-app-env'
  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
  select_json '.data'
  assert_json '.RAILS_ENV' 'production'
  assert_json '.EXAMPLE' 'okay'
}
