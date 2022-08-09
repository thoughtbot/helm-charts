#!/usr/bin/env bats

load helpers

@test "attaches Kubernetes secrets" {
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
    defaults:
      container:
        envFrom:
        - secretRef:
            name: postgres
YAML

  select_object 'Deployment' 'example-app-web'
  assert_json '.metadata.namespace' 'default'
  select_json '.spec'
  select_json '.template'
  select_json '.spec'
  assert_json '.containers[0].envFrom[0].secretRef.name' 'postgres'
}

@test "attaches CSI secrets" {
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
    defaults:
      container:
        envFrom:
        - secretRef:
            name: postgres
      csiSecrets:
      - postgres
YAML

  select_object 'Deployment' 'example-app-web'
  assert_json '.metadata.namespace' 'default'
  select_json '.spec'
  select_json '.template'
  select_json '.spec'
  assert_json '.containers[0].envFrom[0].secretRef.name' 'postgres'
  assert_json '.containers[0].volumeMounts[0].name' 'postgres'
  assert_json '.containers[0].volumeMounts[0].mountPath' '/csiSecrets/postgres'
  assert_json '.containers[0].volumeMounts[0].readOnly' 'true'
  assert_json '.volumes[0].name' 'postgres'
  assert_json '.volumes[0].csi.driver' 'secrets-store.csi.k8s.io'
  assert_json '.volumes[0].csi.readOnly' 'true'
  assert_json '.volumes[0].csi.volumeAttributes.secretProviderClass' 'postgres'
}
