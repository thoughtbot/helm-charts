#!/usr/bin/env bats

load helpers

@test "generates a default virtual service entry" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      version: abc123
    namespaces:
    - name: default
      hosts:
      - default.example.com
      virtualservice:
        enabled: true
    services:
      example:
        containers:
          example:
            http: {}
        virtualservice:
          matchprefix: /example
YAML

  select_object 'VirtualService' 'default-example-app-virtualservice'
  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
  select_json '.spec'
  assert_json '.hosts[0]' 'default.example.com'
  assert_json '.http[0].match[0].uri.prefix' '/example'
  assert_json '.http[0].route[0].destination.host' 'example-app-example'
  assert_json '.http[0].route[0].destination.port.number' '3000'
  assert_json '.http[0].corsPolicy' 'null'
  assert_json '.http[0].retries.attempts' '0'
  assert_json '.http[0].timeout' '15s'
}

@test "generates a custom virtual service entry" {
  render <<-YAML
    app:
      instance: "example-app-production"
      name: "example-app"
      version: abc123
    namespaces:
    - name: default
      hosts:
      - default.example.com
      virtualservice:
        enabled: true
    services:
      example:
        containers:
          example:
            http:
              port: 5000
        virtualservice:
          corsPolicy:
            allowHeaders:
            - x-example
          matchprefix: /example
          retries:
            attempts: 2
          timeout: 30s
YAML

  select_object 'VirtualService' 'default-example-app-virtualservice'
  assert_json '.metadata.namespace' 'default'
  assert_label 'app.kubernetes.io/instance' 'example-app-production'
  assert_label 'app.kubernetes.io/name' 'example-app'
  assert_label 'app.kubernetes.io/version' 'abc123'
  select_json '.spec'
  assert_json '.hosts[0]' 'default.example.com'
  assert_json '.http[0].match[0].uri.prefix' '/example'
  assert_json '.http[0].route[0].destination.host' 'example-app-example'
  assert_json '.http[0].route[0].destination.port.number' '5000'
  assert_json '.http[0].corsPolicy.allowHeaders[0]' 'x-example'
  assert_json '.http[0].retries.attempts' '2'
  assert_json '.http[0].timeout' '30s'
}
