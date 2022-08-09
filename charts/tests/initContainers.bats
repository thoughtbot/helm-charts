#!/usr/bin/env bats

load helpers

@test "adds init containers" {
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
        initContainers:
          rails:
            name: migrations
            args:
            - rails
            - db:abort_if_pending_migrations
YAML

  select_object 'Deployment' 'example-app-web'
  select_json '.spec'
  select_json '.template'
  select_json '.spec'
  assert_json '.containers[0].name' 'rails'
  assert_json '.containers[0].args[0]' 'rails'
  assert_json '.containers[0].args[1]' 'server'
  assert_json '.initContainers[0].name' 'migrations'
  assert_json '.initContainers[0].args[0]' 'rails'
  assert_json '.initContainers[0].args[1]' 'db:abort_if_pending_migrations'
  assert_json '.initContainers[0].ports[0]' 'null'
}
